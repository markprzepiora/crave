require 'spec_helper'

describe Crave do
  it "has a version number" do
    Crave::VERSION.should_not be_nil
  end

  describe ".register_dependency" do
    it "works" do
      Crave.register_dependency(:ruby, Crave::Dependency::Ruby)
      Crave::DEPENDENCY_KLASSES['ruby'].should == Crave::Dependency::Ruby
    end
  end
end
