require 'crave/dependency/options'

describe Crave::Dependency::Options do
  it "can be initialized with minimal params" do
    options_klass = Crave::Dependency::Options.class_factory
    options_klass.new({}).options_hash.should == {}
  end

  it "creates readers" do
    options_klass = Crave::Dependency::Options.class_factory([:foo, :bar])
    options = options_klass.new(:foo => 1, 'bar' => 2)
    options.foo.should == 1
    options.bar.should == 2
  end

  it "answers true to #respond_to? for the defined attrs" do
    options_klass = Crave::Dependency::Options.class_factory([:foo, :bar])
    options = options_klass.new(:foo => 1, 'bar' => 2)

    options.should respond_to(:foo)
    options.should respond_to(:bar)
    options.should_not respond_to(:baz)
  end

  it "creates setters" do
    options_klass = Crave::Dependency::Options.class_factory([:foo, :bar])
    options = options_klass.new(foo: 1)
    options.foo = 111
    options.bar = 222
    options.foo.should == 111
    options.bar.should == 222
  end

  it "can prepend array options with another array" do
    options_klass = Crave::Dependency::Options.class_factory([], where: ['baz'])
    options = options_klass.new(where: ['foo', 'bar'])
    options.where.should == %w(foo bar baz)
  end

  it "can prepend array options with a single value" do
    options_klass = Crave::Dependency::Options.class_factory([], where: ['bar'])
    options = options_klass.new(where: 'foo')
    options.where.should == %w(foo bar)
  end
end
