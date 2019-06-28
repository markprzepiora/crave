# typed: true

require 'crave'
require 'sorbet-runtime'

class Crave::Dependency::Base::VersionedInstallation < Crave::Dependency::Base::Installation
  extend T::Sig
  extend T::Helpers
  abstract!

  attr_reader :exe

  sig{ params(exe: String).void }
  def initialize(exe)
    @exe = exe
  end

  sig{ params(dependency: Crave::Dependency::Base).returns(T::Boolean) }
  def satisfies_dependency?(dependency)
    Gem::Requirement.new(*dependency.options.version).satisfied_by?(version)
  end

  sig{ abstract.returns(Crave::SatisfiedDependency) }
  def to_satisfied_dependency
    fail ArgumentError, "must implement me"
  end

  sig{ params(other: Object).returns(T::Boolean) }
  def ==(other)
    if other.is_a?(Crave::Dependency::Base::VersionedInstallation)
      File.realpath(exe) == File.realpath(other.exe)
    else
      super
    end
  end

  private

  sig{ returns(String) }
  def version_string
    @version_string ||= begin
      out = system_out(exe, *version_args).chomp
      match = out.match(version_regex)
      [(match && match.captures.first) || "0.0"]
    end
    @version_string[0]
  end

  sig{ returns(Gem::Version) }
  def version
    @version ||= begin
      Gem::Version.create(version_string)
    rescue ArgumentError => e
      Gem::Version.create("0.0")
    end
  end

  sig{ returns(T::Array[String]) }
  def version_args
    ['--version']
  end

  sig{ returns(Regexp) }
  def version_regex
    /(.*)/
  end
end
