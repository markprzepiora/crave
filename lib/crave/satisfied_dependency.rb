require 'crave'

class Crave::SatisfiedDependency
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

  # @param commands [Array<Crave::Command>]
  # @return self
  def add_commands(commands)
    not_commands = commands.reject do |command|
      command.is_a?(Crave::Command)
    end

    if not_commands.any?
      fail ArgumentError, "#{not_commands.inspect} are not commands"
    end

    @commands += commands

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
