# typed: true
require 'crave'
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
    def to_satisfied_dependency
      commands = find_commands('postgres', exe,
        %w(createdb createuser dropdb initdb pg_dump pg_restore postgres psql))
      Crave::SatisfiedDependency.new(:postgres).add_commands(commands)
    end

    private

    def version_regex
      %r{^postgres \(PostgreSQL\) ([0-9\.]+)}
    end
  end
end
