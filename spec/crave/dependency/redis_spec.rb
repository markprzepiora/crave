require 'crave/dependency/redis'
require 'fileutils'

describe Crave::Dependency::Redis do
  before do
    Dir.glob(fixture_path('redis-*/redis-server')).each do |exe|
      FileUtils.chmod('+x', exe)
    end
  end

  describe "#find_installations" do
    it "returns a lazy enumerator" do
      redis_dependency = Crave::Dependency::Redis.new
      installations = redis_dependency.find_installations
      installations.should be_an(Enumerator::Lazy)
    end

    it 'finds a redis executable' do
      redis_dependency = Crave::Dependency::Redis.new
      redis_dependency.options.where = [fixture_path('redis-3.1')]

      last_installation = redis_dependency.find_installations.to_a[-1]
      last_installation.exe.should end_with(fixture_path('redis-3.1/redis-server'))
    end
  end

  describe Crave::Dependency::Redis::Installation do
    it "reads the version number" do
      installation = Crave::Dependency::Redis::Installation.new(fixture_path('redis-3.1/redis-server'))

      installation.should be_match('3.1.0')
      installation.should be_match('3.1')
    end

    it "matches exact version numbers" do
      installation = Crave::Dependency::Redis::Installation.new(fixture_path('redis-4.0.9/redis-server'))

      installation.should_not be_match('4.0.0')
      installation.should_not be_match('4.0.8')
      installation.should_not be_match('4.1')
    end

    it "matches version specifiers" do
      installation = Crave::Dependency::Redis::Installation.new(fixture_path('redis-4.0.9/redis-server'))

      installation.should_not be_match('~> 4.1.5')
      installation.should be_match('~> 4.0')
      installation.should be_match('~> 4.0.1')
      installation.should be_match('>= 4', '< 5')
      installation.should_not be_match('>= 4', '< 4.0.9')
    end
  end
end
