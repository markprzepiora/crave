require 'crave/dependency/base'
require 'crave/dependency/base/versioned_installation'
require 'open3'

class Crave::Dependency::Postgres < Crave::Dependency::Base
  options where: %w(
    /usr/bin
    /usr/local/bin
    /usr/lib/postgresql
    /usr/local/Cellar/postgresql
    /home/linuxbrew/.linuxbrew/Cellar/postgresql
    /usr
  )

  def find_installations
    cmd_names = %w( postgres )

    find_executables(cmd_names, where: options.where).select do |cmd|
      postgres?(cmd)
    end.map do |cmd|
      Installation.new(cmd)
    end
  end

  private

  def postgres?(cmd)
    system_out(cmd, "--version").include?('postgres (PostgreSQL)')
  end

  class Installation < Crave::Dependency::Base::VersionedInstallation
    def to_dependency
    end

    def to_envrc
    end

    private

    def version_regex
      %r{^postgres \(PostgreSQL\) ([0-9\.]+)}
    end
  end
end
