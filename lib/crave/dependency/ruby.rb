require 'crave/dependency/base'
require 'crave/dependency/base/versioned_installation'
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

  class Installation < Crave::Dependency::Base::VersionedInstallation
    def to_dependency
    end

    def to_envrc
    end

    private

    def version_args
      [ "--disable-gems", "-e", "puts RUBY_VERSION" ]
    end
  end
end
