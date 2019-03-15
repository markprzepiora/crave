require 'crave/dependencies_file'

describe Crave::DependenciesFile do
  it "evaluates a trivial file" do
    deps = Crave::DependenciesFile.from_text("").evaluate
    deps.evaluated_dependencies.should == []
    deps.errors.should == []
    deps.should be_complete
  end

  xit "parses a simple file" do
    dependencies_file_text = <<-TEXT
      dependency 'ruby', '>= 2'
    TEXT
  end
end
