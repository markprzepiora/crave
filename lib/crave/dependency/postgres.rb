# typed: true
require 'crave'
require 'open3'
require "sorbet-runtime"

class Crave::Dependency::Postgres < Crave::Dependency::Base
  extend T::Sig

  options where: %w(
    /usr/bin
    /usr/local/bin
    /usr/lib/postgresql
    /usr/local/Cellar/postgresql
    /home/linuxbrew/.linuxbrew/Cellar/postgresql
    /usr
  )

  sig{ implementation.returns(T::Enumerator[Installation]) }
  def find_installations
    cmd_names = %w( postgres )

    find_executables(cmd_names, where: options.where).lazy.select do |cmd|
      postgres?(cmd)
    end.map do |cmd|
      Installation.new(cmd)
    end
  end

  private

  sig{ params(cmd: String).returns(T::Boolean) }
  def postgres?(cmd)
    system_out([cmd, "--version"]).include?('postgres (PostgreSQL)')
  end

  class Installation < Crave::Dependency::Base::VersionedInstallation
    sig{ implementation.returns(Crave::SatisfiedDependency) }
    def to_satisfied_dependency
      commands = find_commands('postgres', exe,
        %w(createdb createuser dropdb initdb pg_dump pg_restore postgres psql))
      Crave::SatisfiedDependency.new(:postgres).add_commands(commands)
    end

    private

    sig{ returns(Regexp) }
    def version_regex
      %r{^postgres \(PostgreSQL\) ([0-9\.]+)}
    end
  end
end
