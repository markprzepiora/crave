require 'crave/dependency/base'

describe Crave::Dependency::Base do
  it 'keeps option names separate' do
    klass_1 = Class.new(Crave::Dependency::Base) do
      options :foo, :bar
    end

    klass_2 = Class.new(Crave::Dependency::Base) do
      options :baz
    end

    klass_1.option_names.should == %w(where foo bar)
    klass_2.option_names.should == %w(where baz)
  end

  it 'has an options object' do
    klass = Class.new(Crave::Dependency::Base) do
      options :foo, :bar
    end
    dependency = klass.new(foo: 'xxx')
    dependency.options.foo.should == 'xxx'
  end

  it 'allows default options to be set' do
    klass = Class.new(Crave::Dependency::Base) do
      options :foo, where: ['/usr/bin'], bar: 123
    end

    dependency = klass.new

    dependency.options.foo.should == nil
    dependency.options.where.should == ['/usr/bin']
    dependency.options.bar.should == 123
  end
end
