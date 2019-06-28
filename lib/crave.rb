# typed: true
require "crave/version"
require "sorbet-runtime"

module Crave
  extend T::Sig

  autoload(:Command, 'crave/command')
  autoload(:DependenciesFile, 'crave/dependencies_file')
  autoload(:Dependency, 'crave/dependency')
  autoload(:FindExecutables, 'crave/find_executables')
  autoload(:SatisfiedDependency, 'crave/satisfied_dependency')
  autoload(:Serializers, 'crave/serializers')
  autoload(:Support, 'crave/support')

  DEPENDENCY_KLASSES = {}

  sig{ params(name: T.any(String, Symbol), klass: T.class_of(Crave::Dependency::Base)).void }
  def self.register_dependency(name, klass)
    DEPENDENCY_KLASSES[name.to_s] = klass
  end

  sig{ params(name: T.any(String, Symbol)).returns(T.class_of(Crave::Dependency::Base)) }
  def self.lookup_dependency_klass(name)
    DEPENDENCY_KLASSES.fetch(name.to_s) do
      fail ArgumentError,
        "could not find dependency class for '#{name}', " +
        "valid names are: #{DEPENDENCY_KLASSES.keys.join(', ')}"
    end
  end
end
