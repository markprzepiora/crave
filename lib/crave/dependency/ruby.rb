require 'crave/dependency/base'
require 'open3'

class Crave::Dependency::Ruby < Crave::Dependency::Base
  options where: %w( /usr/bin /usr/local/bin ~/.rubies/ruby*/bin ~/.rvm )

  def find_installations
    cmd_names = %w(
      ruby
      ruby1.8 ruby1.9
      ruby2 ruby2.0 ruby2.1 ruby2.2 ruby2.3 ruby2.4 ruby2.5 ruby2.6 ruby 2.7 ruby2.8 ruby2.9
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

  class Installation
    attr_reader :exe

    def initialize(ruby_executable)
      @exe = ruby_executable
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
      @version_string ||= [system_out(exe, "--disable-gems", "-e", "puts RUBY_VERSION").chomp]
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
