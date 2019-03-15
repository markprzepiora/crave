require_relative '../crave'
require_relative 'serializers/direnv_serializer'

class Crave::DependenciesFile
  attr_reader :evaluated_dependencies

  def initialize(dependencies_file_text)
    @evaluated_dependencies = []
    @text = dependencies_file_text
  end

  def evaluate
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
