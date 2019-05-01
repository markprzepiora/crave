require 'spec_helper'
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
    def redis_dependency(*version)
      Crave::Dependency::Redis.new(version: version)
    end

    it "reads the version number" do
      installation = Crave::Dependency::Redis::Installation.new(fixture_path('redis-3.1/redis-server'))

      installation.should satisfy_dependency(redis_dependency('3.1.0'))
      installation.should satisfy_dependency(redis_dependency('3.1'))
    end

    it "matches exact version numbers" do
      installation = Crave::Dependency::Redis::Installation.new(fixture_path('redis-4.0.9/redis-server'))

      installation.should_not satisfy_dependency(redis_dependency('4.0.0'))
      installation.should_not satisfy_dependency(redis_dependency('4.0.8'))
      installation.should_not satisfy_dependency(redis_dependency('4.1'))
    end

    it "matches version specifiers" do
      installation = Crave::Dependency::Redis::Installation.new(fixture_path('redis-4.0.9/redis-server'))

      installation.should_not satisfy_dependency(redis_dependency('~> 4.1.5'))
      installation.should satisfy_dependency(redis_dependency('~> 4.0'))
      installation.should satisfy_dependency(redis_dependency('~> 4.0.1'))
      installation.should satisfy_dependency(redis_dependency('>= 4', '< 5'))
      installation.should_not satisfy_dependency(redis_dependency('>= 4', '< 4.0.9'))
    end

    describe "#to_satisfied_dependency" do
      let(:installation) { Crave::Dependency::Redis::Installation.new(fixture_path('redis-3.1/redis-server')) }
      let(:satisfied_dependency) { installation.to_satisfied_dependency }
      let(:env) { satisfied_dependency.env }
      let(:commands) { satisfied_dependency.commands }
      let(:prepend_paths) { satisfied_dependency.prepend_paths }

      it "does not set any environment variables" do
        env.should == {}
      end

      it "sets commands" do
        commands.map(&:name).should match_array(
          %w( redis-cli redis-server ))
      end

      it "does not set any PATHs" do
        prepend_paths.length.should == 0
      end
    end
  end
end
