require 'crave/dependency/base'
require 'crave/dependency/base/versioned_installation'
require 'crave/satisfied_dependency'
require 'json'
require 'open3'

class Crave::Dependency::Ruby < Crave::Dependency::Base
  options where: %w( /usr/bin /usr/local/bin ~/.rubies/ruby*/bin ~/.rvm )

  def find_installations
    cmd_names = %w(
      ruby
      ruby1.8 ruby1.9
      ruby2 ruby2.0 ruby2.1 ruby2.2 ruby2.3 ruby2.4 ruby2.5 ruby2.6 ruby2.7 ruby2.8 ruby2.9
      ruby3 ruby3.0 ruby3.1 ruby3.2
    )

    find_executables(cmd_names, where: options.where).select do |cmd|
      ruby?(cmd)
    end.map do |cmd|
      Installation.new(cmd)
    end
  end

  private

  def ruby?(cmd)
    system_out(cmd, "--version") =~ /^ruby \d/
  end

  class Installation < Crave::Dependency::Base::VersionedInstallation
    def to_satisfied_dependency
      commands = find_commands('ruby', exe, %w( erb gem irb rake rdoc ri ruby ))

      code = %q<
        env = {}
        env['RUBY_ENGINE'] = Object.const_defined?(:RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
        env['RUBY_VERSION'] = RUBY_VERSION

        begin
          require 'rubygems'
          env['GEM_ROOT'] = Gem.default_dir
        rescue LoadError
        end

        puts JSON.pretty_generate(env)
      >

      env = JSON.load(system_out(exe, "-rjson", "-e", code))
      env['GEM_HOME'] = File.join(Dir.home, ".gem", env['RUBY_ENGINE'], env['RUBY_VERSION'])
      env['GEM_PATH'] = "#{env['GEM_HOME']}:#{env['GEM_ROOT']}"
      env

      Crave::SatisfiedDependency.new(:ruby).
        add_commands(commands).
        add_env(env).
        add_prepend_paths(File.join(env['GEM_HOME'], 'bin'), File.join(env['GEM_ROOT'], 'bin'))
    end

    private

    def version_args
      [ "--disable-gems", "-e", "puts RUBY_VERSION" ]
    end
  end
end
