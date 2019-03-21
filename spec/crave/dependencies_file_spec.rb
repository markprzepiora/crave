require 'crave/dependencies_file'
require 'crave/dependency/base'
require 'crave/satisfied_dependency'

describe Crave::DependenciesFile do
  it "evaluates a trivial file" do
    deps = Crave::DependenciesFile.from_text("").evaluate
    deps.dependencies.should == []
    deps.evaluated_dependencies.should == []
    deps.errors.should == []
    deps.should be_satisfied
    deps.to_envrc.strip.should == <<-TEXT.strip
# Finally, add the .bin directory to the path
PATH_add .bin
    TEXT
  end

  class GoodDependency < Crave::Dependency::Base
    options :foo

    def find_installations
      return to_enum(__callee__).lazy unless block_given?
      yield Installation.new
    end

    class Installation
      def to_satisfied_dependency
        Crave::SatisfiedDependency.new(:good).add_env({ FOO: 'bar' })
      end

      def satisfies_dependency?(*args)
        true
      end
    end
  end

  it "parses a simple file" do
    Crave.register_dependency(:good, GoodDependency)

    dependencies_file_text = <<-TEXT
      dependency 'good', '>= 2', foo: 123
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate

    deps.dependencies.length.should == 1
    deps.should be_satisfied

    dependency = deps.dependencies.first
    dependency.options.version.should == ['>= 2']
    dependency.options.foo.should == 123
  end

  it "resolves a simple file's dependencies" do
    Crave.register_dependency(:good, GoodDependency)

    dependencies_file_text = <<-TEXT
      dependency 'good', '>= 2', foo: 123
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate
    deps.should be_satisfied

    deps.to_envrc.strip.should == <<-TEXT.strip
# good
export FOO="bar"
mkdir -p .bin

# Finally, add the .bin directory to the path
PATH_add .bin
    TEXT
  end
end
