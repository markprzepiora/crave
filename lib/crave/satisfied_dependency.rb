require_relative '../crave'

class Crave::SatisfiedDependency
  class Command < Struct.new(:satisfied_dependency, :name, :path)
    def valid?
      File.exists?(path) &&
      File.file?(path) &&
      File.executable?(path)
    end

    def errors
      if valid?
        []
      else
        ["Command #{name} (from software #{satisfied_dependency.name}) " +
         "does not exist or is not executable at #{path}"]
      end
    end
  end

  attr_reader :name, :commands, :env, :prepend_paths

  def initialize(name)
    @name = name.to_sym
    @commands = []
    @env = {}
    @prepend_paths = []
  end

  def valid?
    commands_valid?
  end

  def errors
    commands.map(&:errors).flatten(1)
  end

  def add_commands(hash_or_array)
    if hash_or_array.empty?
      return self
    end

    if hash_or_array.is_a?(Hash)
      @commands += hash_or_array.map do |name, path|
        Command.new(self, name, path)
      end
    elsif hash_or_array.is_a?(Array) && hash_or_array.first.is_a?(Command)
      @commands += hash_or_array.map{ |cmd| Command.new(self, cmd.name, cmd.path) }
    else
      fail "cannot add commands from object #{hash_or_array}"
    end

    self
  end

  def add_env(hash)
    @env = @env.merge(hash)
    self
  end

  def add_prepend_paths(*paths)
    @prepend_paths = [*paths, *@prepend_paths]
    self
  end

  private

  def commands_valid?
    !invalid_commands.any?
  end

  def invalid_commands
    commands.reject(&:valid?)
  end
end
