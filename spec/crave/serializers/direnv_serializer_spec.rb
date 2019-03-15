require 'crave/serializers/direnv_serializer'
require 'crave/satisfied_dependency'

describe Crave::Serializers::DotenvSerializer do
  it "serializes a trivial satisfied dependency" do
    satisfied_dependency = Crave::SatisfiedDependency.new(:foo)
    envrc_string = Crave::Serializers::DotenvSerializer.serialize(satisfied_dependency)

    envrc_string.should include("# foo\n")
    envrc_string.should include("mkdir -p .bin\n")
  end

  it "serializes environment variables" do
    satisfied_dependency =
      Crave::SatisfiedDependency.new(:foo).
      add_env({ SOME_VAR: 'foo bar "baz"' })
    envrc_string = Crave::Serializers::DotenvSerializer.serialize(satisfied_dependency)

    envrc_string.should include('export SOME_VAR="foo bar \"baz\""' + "\n")
  end

  it "serializes commands" do
    satisfied_dependency =
      Crave::SatisfiedDependency.new(:foo).
      add_commands(ruby: '/usr/bin/ruby')
    envrc_string = Crave::Serializers::DotenvSerializer.serialize(satisfied_dependency)

    envrc_string.should include('ln -sf "/usr/bin/ruby" ".bin/ruby"' + "\n")
  end

  it "serializes prepend-paths" do
    satisfied_dependency =
      Crave::SatisfiedDependency.new(:foo).
      add_prepend_paths("/foo/bar/baz")
    envrc_string = Crave::Serializers::DotenvSerializer.serialize(satisfied_dependency)

    envrc_string.should include('PATH_add "/foo/bar/baz"' + "\n")
  end
end
