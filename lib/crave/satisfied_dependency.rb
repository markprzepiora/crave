# typed: true
require 'crave'

class Crave::SatisfiedDependency
  extend T::Sig

  attr_reader :name, :commands, :env, :prepend_paths

  sig{ params(name: Symbol).void }
  def initialize(name)
    @name = name.to_sym
    @commands = []
    @env = {}
    @prepend_paths = []
  end

  sig{ returns(T::Boolean) }
  def valid?
    commands_valid?
  end

  sig{ returns(T::Array[String]) }
  def errors
    commands.map(&:errors).flatten(1)
  end

  sig{ params(commands: T::Array[Crave::Command]).returns(T.self_type) }
  # @param commands [Array<Crave::Command>]
  # @return self
  def add_commands(commands)
    @commands += commands
    self
  end

  sig{ params(hash: T::Hash[T.any(String, Symbol), String]).returns(T.self_type) }
  def add_env(hash)
    @env = @env.merge(hash)
    self
  end

  sig{ params(paths: String).returns(T.self_type) }
  def add_prepend_paths(*paths)
    @prepend_paths = [*paths, *@prepend_paths]
    self
  end

  private

  sig{ returns(T::Boolean) }
  def commands_valid?
    !invalid_commands.any?
  end

  sig{ returns(T::Array[Crave::Command]) }
  def invalid_commands
    commands.reject(&:valid?)
  end
end
