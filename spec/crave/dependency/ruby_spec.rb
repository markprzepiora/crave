require 'crave/dependency/ruby'
require 'fileutils'

describe Crave::Dependency::Ruby do
  before do
    Dir.glob(fixture_path('ruby-*/ruby')).each do |exe|
      FileUtils.chmod('+x', exe)
    end
  end

  describe "#find_installations" do
    it "returns a lazy enumerator" do
      ruby_dependency = Crave::Dependency::Ruby.new
      installations = ruby_dependency.find_installations
      installations.should be_an(Enumerator::Lazy)
    end

    it 'finds a ruby executable' do
      ruby_dependency = Crave::Dependency::Ruby.new
      ruby_dependency.options.where = [fixture_path('ruby-2.4.0')]

      last_installation = ruby_dependency.find_installations.to_a[-1]
      last_installation.exe.should end_with(fixture_path('ruby-2.4.0/ruby'))
    end
  end
end
