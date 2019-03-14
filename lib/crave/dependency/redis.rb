require 'crave/dependency/base'
require 'crave/dependency/base/versioned_installation'
require 'open3'

class Crave::Dependency::Redis < Crave::Dependency::Base
  options where: %w( /usr/bin /usr/local/bin ~/.rubies/ruby*/bin ~/.rvm )

  def find_installations
    cmd_names = %w( redis-server )

    find_executables(cmd_names, where: options.where).select do |cmd|
      redis?(cmd)
    end.map do |cmd|
      Installation.new(cmd)
    end
  end

  private

  def redis?(cmd)
    system_out(cmd, "--version") =~ /^Redis server/
  end

  class Installation < Crave::Dependency::Base::VersionedInstallation
    def to_satisfied_dependency
    end

    def to_envrc
    end

    private

    def version_args
      [ '--version' ]
    end

    def version_regex
      %r{Redis server v=([0-9\.]+)}
    end
  end
end
