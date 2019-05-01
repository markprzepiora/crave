require 'spec_helper'

describe Crave::Serializers::DirenvSerializer do
  describe ".serialize" do
    it "serializes a trivial satisfied dependency" do
      satisfied_dependency = Crave::SatisfiedDependency.new(:foo)
      envrc_string = Crave::Serializers::DirenvSerializer.serialize(satisfied_dependency)

      envrc_string.should include("# foo\n")
      envrc_string.should include("mkdir -p .bin\n")
    end

    it "serializes environment variables" do
      satisfied_dependency =
        Crave::SatisfiedDependency.new(:foo).
        add_env({ SOME_VAR: 'foo bar "baz"' })
      envrc_string = Crave::Serializers::DirenvSerializer.serialize(satisfied_dependency)

      envrc_string.should include('export SOME_VAR="foo bar \"baz\""' + "\n")
    end

    it "serializes commands" do
      command = Crave::Command.new('ruby', '/usr/bin/ruby')
      satisfied_dependency = Crave::SatisfiedDependency.new(:foo).add_commands([command])
      envrc_string = Crave::Serializers::DirenvSerializer.serialize(satisfied_dependency)

      envrc_string.should include('ln -sf "/usr/bin/ruby" ".bin/ruby"' + "\n")
    end

    it "serializes prepend-paths" do
      satisfied_dependency =
        Crave::SatisfiedDependency.new(:foo).
        add_prepend_paths("/foo/bar/baz")
      envrc_string = Crave::Serializers::DirenvSerializer.serialize(satisfied_dependency)

      envrc_string.should include('PATH_add "/foo/bar/baz"' + "\n")
    end
  end

  describe ".serialize_many" do
    it "serializes all given satisfied dependencies and adds the .bin directory to the path" do
      satisfied_dependency_1 = Crave::SatisfiedDependency.new(:foo)
      satisfied_dependency_2 = Crave::SatisfiedDependency.new(:bar)
      envrc_string = Crave::Serializers::DirenvSerializer.serialize_many(
        [satisfied_dependency_1, satisfied_dependency_2])

      envrc_string.should == <<-TEXT
# foo
mkdir -p .bin

# bar
mkdir -p .bin

# Finally, add the .bin directory to the path
PATH_add .bin
      TEXT
    end
  end
end
