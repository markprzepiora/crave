# typed: true
require 'crave'
require 'open3'

class Crave::Dependency::Redis < Crave::Dependency::Base
  options where: %w( /usr/bin /usr/local/bin ~/.rubies/ruby*/bin ~/.rvm )

  sig{ implementation.returns(T::Enumerator[Installation]) }
  def find_installations
    cmd_names = %w( redis-server )

    find_executables(cmd_names, where: options.where).lazy.select do |cmd|
      redis?(cmd)
    end.map do |cmd|
      Installation.new(cmd)
    end
  end

  private

  sig{ params(cmd: String).returns(T::Boolean) }
  def redis?(cmd)
    !!(system_out([cmd, "--version"]) =~ /^Redis server/)
  end

  class Installation < Crave::Dependency::Base::VersionedInstallation
    sig{ implementation.returns(Crave::SatisfiedDependency) }
    def to_satisfied_dependency
      commands = find_commands('redis-server', exe, %w( redis-server redis-cli ))
      Crave::SatisfiedDependency.new(:redis).add_commands(commands)
    end

    private

    sig{ returns(T::Array[String]) }
    def version_args
      [ '--version' ]
    end

    sig{ returns(Regexp) }
    def version_regex
      %r{Redis server v=([0-9\.]+)}
    end
  end
end
