require 'spec_helper'

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

      yield UnsatisfyingInstallation.new
      yield SatisfyingInstallation.new
    end

    class UnsatisfyingInstallation < Crave::Dependency::Base::Installation
      def initialize
      end

      def to_satisfied_dependency
        Crave::SatisfiedDependency.new(:good).add_env({ FOO: 'baz' })
      end

      def satisfies_dependency?(*args)
        false
      end
    end

    class SatisfyingInstallation < Crave::Dependency::Base::Installation
      def initialize
      end

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
      dependency 'good', '>= 2'
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate

    deps.dependencies.length.should == 1
    deps.should be_satisfied

    dependency = deps.dependencies.first
    dependency.options.version.should == ['>= 2']
  end

  it "parses a simple dependency without any version spec or other options" do
    Crave.register_dependency(:good, GoodDependency)

    dependencies_file_text = <<-TEXT
      dependency 'good'
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate

    deps.dependencies.length.should == 1
    deps.should be_satisfied

    dependency = deps.dependencies.first
    dependency.options.version.should == []
  end

  it "parses a dependency with only options" do
    Crave.register_dependency(:good, GoodDependency)

    dependencies_file_text = <<-TEXT
      dependency 'good', foo: 999
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate

    deps.dependencies.length.should == 1
    deps.should be_satisfied

    dependency = deps.dependencies.first
    dependency.options.version.should == []
    dependency.options.foo.should == 999
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

  it "resolves the system Ruby dependency (integration test)" do
    Crave.register_dependency(:ruby, Crave::Dependency::Ruby)

    dependencies_file_text = <<-TEXT
      dependency 'ruby'
    TEXT

    deps = Crave::DependenciesFile.from_text(dependencies_file_text).evaluate
    deps.should be_satisfied
    envrc_lines = deps.to_envrc.lines.map(&:chomp)
    envrc_lines.should include('# ruby')
    envrc_lines.should include(match('export GEM_ROOT='))
    envrc_lines.should include(match('export GEM_HOME='))
    envrc_lines.should include(match('export GEM_PATH='))
  end
end
