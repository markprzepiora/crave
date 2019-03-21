require_relative '../crave'
require_relative 'serializers/direnv_serializer'

class Crave::DependenciesFile
  attr_reader :text
  attr_reader :dependencies
  attr_reader :evaluated_dependencies

  class DefineDependenciesContext
    def initialize(dependencies_file)
      @dependencies_file = dependencies_file
    end

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

  def initialize(dependencies_file_text)
    @text = dependencies_file_text
  end

  def evaluate
    @dependencies = []
    DefineDependenciesContext.new(self).instance_eval(text)
    @evaluated_dependencies = dependencies.map do |dep|
      EvaluatedDependency.evaluate(dep)
    end
    self
  end

  def errors
    []
  end

  def satisfied?
    # binding.pry
    evaluated? && evaluated_dependencies.all?(&:satisfied?)
  end

  def to_envrc
    Crave::Serializers::DirenvSerializer.serialize_many(
      evaluated_dependencies.map(&:satisfied_dependency))
  end

  def self.from_text(str)
    new(str)
  end

  private

  def evaluated?
    dependencies && evaluated_dependencies
  end

  class EvaluatedDependency
    attr_reader :dependency, :found_installations, :satisfying_installation

    def initialize(dependency, found_installations, satisfying_installation)
      @dependency = dependency
      @found_installations = found_installations
      @satisfying_installation = satisfying_installation
    end

    def satisfied?
      !!satisfying_installation && satisfied_dependency.valid?
    end

    def satisfied_dependency
      return nil if !satisfying_installation
      @satisfied_dependency ||= satisfying_installation.to_satisfied_dependency
    end

    def self.evaluate(dep)
      found_installations = []
      dep.find_installations do |installation|
        found_installations << installation

        if installation.satisfies_dependency?(dep)
          return new(dep, found_installations, installation)
        end
      end

      new(dep, found_installations, nil)
    end
  end
end
