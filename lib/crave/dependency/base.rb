# typed: false
require 'crave'
require 'open3'
require 'sorbet-runtime'

using Crave::Support

class Crave::Dependency::Base
  extend T::Sig

  autoload(:Installation, 'crave/dependency/base/installation')
  autoload(:VersionedInstallation, 'crave/dependency/base/versioned_installation')

  class << self
    def option_names
      @option_names ||= []
    end

    def default_options
      @default_options ||= {}
    end

    def option_names=(names)
      @option_names = names
    end

    def default_options=(hash)
      @default_options = hash.stringify_keys
      @option_names = (@option_names || []) | hash.keys.map(&:to_s)
    end
  end

  def self.options(*names)
    defaults = if names.last.is_a?(Hash)
      names.pop.stringify_keys
    else
      {}
    end

    names = names.map(&:to_s) + defaults.keys

    self.option_names |= names
    self.default_options = self.default_options.merge(defaults)
  end

  attr_reader :options
  options where: []
  options version: []

  sig{ params(options_hash: Hash).void }
  def initialize(options_hash = {})
    @options = Crave::Dependency::Options.class_factory(
      self.class.option_names, self.class.default_options).new(options_hash)
  end

  def system_out(*args)
    Open3.capture2(*args).first
  end

  def find_executables(*args)
    Crave::FindExecutables.find_executables(*args)
  end

  def self.inherited(subclass)
    subclass.option_names = self.option_names
    subclass.default_options = self.default_options
  end
end
