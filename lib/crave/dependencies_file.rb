require_relative '../crave'
require_relative 'serializers/direnv_serializer'

class Crave::DependenciesFile
  attr_reader :text
  attr_reader :dependencies
  attr_reader :evaluated_dependencies

  class Context
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
    @evaluated_dependencies = []
    @dependencies = []
    @text = dependencies_file_text
  end

  def evaluate
    Context.new(self).instance_eval(text)
    self
  end

  def errors
    []
  end

  def complete?
    true
  end

  def to_envrc
    Crave::Serializers::DirenvSerializer.serialize_many([])
  end

  def self.from_text(str)
    new(str)
  end
end
