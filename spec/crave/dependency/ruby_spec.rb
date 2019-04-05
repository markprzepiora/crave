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
    def ruby_dependency(*version)
      Crave::Dependency::Ruby.new(version: version)
    end

    it "reads the version number" do
      installation = Crave::Dependency::Ruby::Installation.new(fixture_path('ruby-2.4.0/ruby'))

      installation.should satisfy_dependency(ruby_dependency('2.4.0'))
      installation.should satisfy_dependency(ruby_dependency('2.4'))
    end

    it "matches exact version numbers" do
      installation = Crave::Dependency::Ruby::Installation.new(fixture_path('ruby-2.5.1/ruby'))

      installation.should_not satisfy_dependency(ruby_dependency('2.4.1'))
      installation.should_not satisfy_dependency(ruby_dependency('2.5.0'))
      installation.should_not satisfy_dependency(ruby_dependency('2.5'))
    end

    it "matches version specifiers" do
      installation = Crave::Dependency::Ruby::Installation.new(fixture_path('ruby-2.5.1/ruby'))

      installation.should_not satisfy_dependency(ruby_dependency('~> 2.4.1'))
      installation.should satisfy_dependency(ruby_dependency('~> 2.4'))
      installation.should satisfy_dependency(ruby_dependency('~> 2.5.0'))
      installation.should satisfy_dependency(ruby_dependency('>= 2.4', '< 3'))
      installation.should_not satisfy_dependency(ruby_dependency('>= 2.4', '< 2.5'))
    end

    describe "#to_satisfied_dependency" do
      # These tests uses whatever the system ruby currently has. This *ought*
      # to work because, well, we're running these tests with something!
      def system_ruby
        system_paths = ENV['PATH'].split(":")
        system_paths.map do |dir|
          File.join(dir, 'ruby')
        end.find do |ruby_path|
          File.exists?(ruby_path) &&
          File.executable?(ruby_path)
        end
      end

      before(:all) do
        @installation = Crave::Dependency::Ruby::Installation.new(system_ruby)
        @satisfied_dependency = @installation.to_satisfied_dependency
      end

      let(:env) { @satisfied_dependency.env }
      let(:commands) { @satisfied_dependency.commands }
      let(:prepend_paths) { @satisfied_dependency.prepend_paths }

      it "sets environment variables" do
        env.keys.should match_array([
          'RUBY_ENGINE', 'RUBY_VERSION', 'GEM_ROOT', 'GEM_HOME', 'GEM_PATH'
        ])
        env['RUBY_ENGINE'].should == 'ruby'
        env['RUBY_VERSION'].should =~ /^\d/
        File.directory?(env['GEM_ROOT']).should == true
        env['GEM_HOME'].should start_with '/'

        env['GEM_PATH'].split(':').each do |path|
          path.should match(/gem|Gems/)
        end
      end

      it "sets commands" do
        commands.map(&:name).should match_array(
          %w( erb gem irb rdoc ri ruby ))
      end

      it "sets the prepend_paths" do
        prepend_paths.length.should > 0
        prepend_paths.each do |path|
          path.should match(/gem|Gems/)
        end
      end
    end
  end
end
