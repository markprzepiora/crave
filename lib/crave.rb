require "crave/version"

module Crave
  DEPENDENCIES = {}

  def self.register_dependency(name, klass)
    DEPENDENCIES[name.to_s] = klass
  end
end
