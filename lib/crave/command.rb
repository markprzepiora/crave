# typed: true
require 'crave'
require 'sorbet-runtime'

class Crave::Command
  extend T::Sig

  attr_accessor :name, :path

  sig{ params(name: String, path: String).void }
  def initialize(name, path)
    @name = name
    @path = path
  end

  sig{ returns(T::Boolean) }
  def valid?
    !!(File.exists?(path) && File.file?(path) && File.executable?(path))
  end

  sig{ returns(T::Array[String]) }
  def errors
    if valid?
      []
    else
      ["Command #{name} does not exist or is not executable at #{path}"]
    end
  end
end
