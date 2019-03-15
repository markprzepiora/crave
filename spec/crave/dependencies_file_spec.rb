require 'crave/dependencies_file'
require 'crave/dependency/base'
require 'crave/satisfied_dependency'

describe Crave::DependenciesFile do
  it "evaluates a trivial file" do
    deps = Crave::DependenciesFile.from_text("").evaluate
    deps.evaluated_dependencies.should == []
    deps.errors.should == []
    deps.should be_complete
    deps.to_envrc.strip.should == <<-TEXT.strip
# Finally, add the .bin directory to the path
PATH_add .bin
    TEXT
  end

  class GoodDependency < Crave::Dependency::Base
    def find_installations
      [Installation.new]
    end

    class Installation
      def to_satisfied_dependency
        SatisfiedDependency.new(:foo).add_env({ FOO: 'bar' })
      end

      def match?
        true
      end
    end
  end

  it "parses a simple file" do
    Crave.register_dependency(:good, GoodDependency)

    dependencies_file_text = <<-TEXT
      dependency 'good', '>= 2'
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate
    deps.to_envrc.strip.should == <<-TEXT.strip
# good
export FOO="bar"

# Finally, add the .bin directory to the path
PATH_add .bin
    TEXT
  end
end
