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

  describe Crave::Dependency::Ruby::Installation do
    it "reads the version number" do
      installation = Crave::Dependency::Ruby::Installation.new(fixture_path('ruby-2.4.0/ruby'))

      installation.should be_match('2.4.0')
      installation.should be_match('2.4')
    end

    it "matches exact version numbers" do
      installation = Crave::Dependency::Ruby::Installation.new(fixture_path('ruby-2.5.1/ruby'))

      installation.should_not be_match('2.4.1')
      installation.should_not be_match('2.5.0')
      installation.should_not be_match('2.5')
    end

    it "matches version specifiers" do
      installation = Crave::Dependency::Ruby::Installation.new(fixture_path('ruby-2.5.1/ruby'))

      installation.should_not be_match('~> 2.4.1')
      installation.should be_match('~> 2.4')
      installation.should be_match('~> 2.5.0')
      installation.should be_match('>= 2.4', '< 3')
      installation.should_not be_match('>= 2.4', '< 2.5')
    end
  end
end
