require 'crave/dependency/postgres'
require 'fileutils'

describe Crave::Dependency::Postgres do
  before do
    Dir.glob(fixture_path('postgres-*/postgres')).each do |exe|
      FileUtils.chmod('+x', exe)
    end
  end

  describe "#find_installations" do
    it "returns a lazy enumerator" do
      postgres_dependency = Crave::Dependency::Postgres.new
      installations = postgres_dependency.find_installations
      installations.should be_an(Enumerator::Lazy)
    end

    it 'finds a postgres executable' do
      postgres_dependency = Crave::Dependency::Postgres.new
      postgres_dependency.options.where = [fixture_path('postgres-9.4.21')]

      last_installation = postgres_dependency.find_installations.to_a[-1]
      last_installation.exe.should end_with(fixture_path('postgres-9.4.21/postgres'))
    end
  end

  describe Crave::Dependency::Postgres::Installation do
    it "reads the version number" do
      installation = Crave::Dependency::Postgres::Installation.new(fixture_path('postgres-9.4.21/postgres'))

      installation.should be_match('9.4.21')
      installation.should_not be_match('9.4')
    end

    it "matches exact version numbers" do
      installation = Crave::Dependency::Postgres::Installation.new(fixture_path('postgres-9.5.21/postgres'))

      installation.should_not be_match('9.4.1')
      installation.should_not be_match('9.5.0')
      installation.should_not be_match('9.5')
    end

    it "matches version specifiers" do
      installation = Crave::Dependency::Postgres::Installation.new(fixture_path('postgres-9.5.21/postgres'))

      installation.should_not be_match('~> 9.4.1')
      installation.should be_match('~> 9.4')
      installation.should be_match('~> 9.5.0')
      installation.should be_match('>= 9.4', '< 10')
      installation.should_not be_match('>= 9.4', '< 9.5')
    end

    describe "#to_satisfied_dependency" do
      let(:installation) {
        Crave::Dependency::Postgres::Installation.new(fixture_path('postgres-9.4.21/postgres')) }
      let(:satisfied_dependency) { installation.to_satisfied_dependency }
      let(:env) { satisfied_dependency.env }
      let(:commands) { satisfied_dependency.commands }
      let(:prepend_paths) { satisfied_dependency.prepend_paths }

      it "does not set any environment variables" do
        env.should == {}
      end

      it "sets commands" do
        commands.map(&:name).should match_array(
          %w(createdb createuser dropdb initdb pg_dump pg_restore postgres psql))
      end

      it "does not set any PATHs" do
        prepend_paths.length.should == 0
      end
    end
  end
end
