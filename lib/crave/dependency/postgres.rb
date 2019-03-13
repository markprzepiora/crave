require 'crave/dependency/base'
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

  class Installation
    attr_reader :exe

    def initialize(postgres_executable)
      @exe = postgres_executable
    end

    def match?(*version_specifier)
      Gem::Requirement.new(*version_specifier).satisfied_by?(version)
    end

    def to_dependency
    end

    def ==(other_ruby)
    end

    def to_envrc
    end

    private

    def version_string
      @version_string ||= begin
        out = system_out(exe, "--version").chomp
        match = out.match(%r{^postgres \(PostgreSQL\) ([0-9\.]+)})
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

    def system_out(*args)
      Open3.capture2(*args).first
    end
  end
end
