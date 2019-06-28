# typed: true
require 'crave'
require 'sorbet-runtime'

class Crave::DependenciesFile
  extend T::Sig

  # @return [String] The contents of the dependencies file.
  attr_reader :text

  # @return [Array<Crave::Dependency::Base>] The dependencies listed in the
  #   `text`, parsed as Ruby objects.
  attr_reader :dependencies

  # @return [Array<Crave::DependenciesFile::EvaluatedDependency>] The result of
  #   attempting to evaluate the `dependencies` above. Each evaluated
  #   dependency is populated with the dependency, as well as all discovered
  #   installations of the dependency program, as well as, possibly, an
  #   installation that satisfies the dependency requirements.
  attr_reader :evaluated_dependencies

  # An instance of this class is the context in which the dependencies file is
  # evaluated. This defines the `dependency` method that is used in the
  # dependencies file.
  class DefineDependenciesContext
    extend T::Sig

    sig{ params(dependencies_file: Crave::DependenciesFile).void }
    def initialize(dependencies_file)
      @dependencies_file = dependencies_file
    end

    # @return [void]
    def dependency(name, *version_and_options)
      options = if version_and_options.last.is_a?(Hash)
        version_and_options.pop
      else
        {}
      end
      version = version_and_options

      dependency_klass = Crave.lookup_dependency_klass(name)
      @dependencies_file.dependencies <<
        dependency_klass.new(options.merge(version: version))
    end
  end

  sig{ params(dependencies_file_text: String).void }
  def initialize(dependencies_file_text)
    @text = dependencies_file_text
  end

  sig{ returns(T.self_type) }
  def evaluate
    @dependencies = []
    DefineDependenciesContext.new(self).instance_eval(text)
    @evaluated_dependencies = dependencies.map do |dep|
      EvaluatedDependency.evaluate(dep)
    end
    self
  end

  sig{ returns(T::Array[String]) }
  def errors
    []
  end

  sig{ returns(T::Boolean) }
  def satisfied?
    evaluated? && evaluated_dependencies.all?(&:satisfied?)
  end

  sig{ returns(String) }
  def to_envrc
    Crave::Serializers::DirenvSerializer.serialize_many(
      evaluated_dependencies.map(&:satisfied_dependency))
  end

  sig{ params(str: String).returns(Crave::DependenciesFile) }
  def self.from_text(str)
    new(str)
  end

  private

  sig{ returns(T::Boolean) }
  def evaluated?
    !!dependencies && !!evaluated_dependencies
  end

  class EvaluatedDependency
    extend T::Sig

    attr_reader :dependency, :found_installations, :satisfying_installation

    sig{
      params(
        dependency: Crave::Dependency::Base,
        found_installations: T::Array[Crave::Dependency::Base::Installation],
        satisfying_installation: T.nilable(Crave::Dependency::Base::Installation),
      ).void
    }
    def initialize(dependency, found_installations, satisfying_installation)
      @dependency = dependency
      @found_installations = found_installations
      @satisfying_installation = satisfying_installation
    end

    sig{ returns(T::Boolean) }
    def satisfied?
      !!satisfied_dependency&.valid?
    end

    sig{ returns(T.nilable(Crave::SatisfiedDependency)) }
    def satisfied_dependency
      return nil if !satisfying_installation
      @satisfied_dependency ||= satisfying_installation.to_satisfied_dependency
    end

    sig{
      params(dep: Crave::Dependency::Base).
      returns(Crave::DependenciesFile::EvaluatedDependency)
    }
    def self.evaluate(dep)
      found_installations = []
      dep.find_installations.each do |installation|
        found_installations << installation

        if installation.satisfies_dependency?(dep)
          return new(dep, found_installations, installation)
        end
      end

      new(dep, found_installations, nil)
    end
  end
end
