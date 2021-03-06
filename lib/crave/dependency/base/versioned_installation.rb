require 'crave'

class Crave::Dependency::Base::VersionedInstallation < Crave::Dependency::Base::Installation
  attr_reader :exe

  def initialize(exe)
    @exe = exe
  end

  def satisfies_dependency?(dependency)
    Gem::Requirement.new(*dependency.options.version).satisfied_by?(version)
  end

  def ==(other)
    if other.is_a?(Crave::Dependency::Base::VersionedInstallation)
      File.realpath(exe) == File.realpath(other.exe)
    else
      super
    end
  end

  private

  def version_string
    @version_string ||= begin
      out = system_out(exe, *version_args).chomp
      match = out.match(version_regex)
      [(match && match.captures.first) || "0.0"]
    end
    @version_string[0]
  end

  def version
    @version ||= begin
      Gem::Version.create(version_string)
    rescue ArgumentError => e
      Gem::Version.create("0.0")
    end
  end

  def version_args
    ['--version']
  end

  def version_regex
    /(.*)/
  end
end
