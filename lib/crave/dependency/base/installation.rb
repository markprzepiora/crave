# typed: false
require 'crave'

using Crave::Support

class Crave::Dependency::Base::Installation
  private

  def system_out(*args)
    Open3.capture2(*args).first
  end

  def satisfies_dependency?(dependency)
    true
  end

  # Here is the problem we're solving:
  #
  # There are multiple ways a program may be symlinked.
  #
  # Type 1:  /usr/local/bin/ruby (link)   -> /usr/local/Cellar/ruby-2,5.1/bin/ruby (real)
  # Type 2:  /usr/bin/ruby (link)         -> /usr/bin/ruby2.4 (real)
  # Type 2:  /usr/bin/redis-server (link) -> /usr/bin/redis-check-rdb (real)
  #
  # In Type 1, (e.g. homebrew/linuxbrew)
  # - real basename = link basename
  # - real dirname != link dirname
  #   (the real executable is in an installation folder, symlinked to /usr/local/bin)
  #
  # In Type 2, (e.g. the Debian/Ubuntu alternatives system)
  # - real basename != link basename
  #   (the real executable is suffixed with the version number, linked to the common name)
  # - real dirname = link dirname
  #
  # In Type 3, (e.g. the busybox design)
  # - real basename != link basename
  #   (as with busybox, the name of the link is significant -- the executable
  #   itself changes behaviour based on the command name)
  # - real dirname = link dirname
  #
  # We want to treat each type differently.
  #
  # Type 1 and Type 2 - These are actually handled the same. We can just resolve
  # the realpath and treat these as version-suffixed commands (with Type 1 having
  # a blank suffix.)
  #
  # Type 3 - These we need to treat manually as not having a suffix. The way we
  # tell between these cases is just by checking whether the link basename is a
  # prefix of the real basename. This should work for most packages, but I can
  # imagine some cases where it may fail, like say if the real busybox is named
  # "foo-server" which is symlinked as "foo". Then the suffix would be detected
  # as "-server" and we would erroneously look for "foo-server-server" and
  # "foo-server" as the commands... If this case ever comes up we can come up
  # with additional heuristics for telling these cases apart.
  #
  # @return [Array<Crave::Command>]
  def find_commands(known_command_name, found_command_path, command_names)
    found_command_basename = File.basename(found_command_path)

    suffix = if found_command_basename.start_with?(known_command_name)
      found_command_basename.gsub(/^#{Regexp.escape(known_command_name)}/, '')
    else
      ""
    end

    dir = File.dirname(found_command_path)

    command_names.map do |command_name|
      Crave::Command.new(command_name, File.join(dir, "#{command_name}#{suffix}"))
    end
  end
end
