require 'crave/dependency/options'

describe Crave::Dependency::Options do
  it "can be initialized with minimal params" do
    options_klass = Crave::Dependency::Options.class_factory
    options_klass.new({}).options_hash.should == {}
  end

  it "creates readers" do
    options_klass = Crave::Dependency::Options.class_factory(:foo, :bar)
    options = options_klass.new(:foo => 1, 'bar' => 2)
    options.foo.should == 1
    options.bar.should == 2
  end

  it "creates setters" do
    options_klass = Crave::Dependency::Options.class_factory(:foo, :bar)
    options = options_klass.new(foo: 1)
    options.foo = 111
    options.bar = 222
    options.foo.should == 111
    options.bar.should == 222
  end
end
