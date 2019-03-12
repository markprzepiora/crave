require_relative '../dependency'
require_relative '../find_executables'
require_relative 'options'
require 'open3'

class Crave::Dependency::Base
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
      @default_options = hash.map{ |k,v| [k.to_s, v] }.to_h
      @option_names = (@option_names || []) | hash.keys.map(&:to_s)
    end
  end

  def self.options(*names)
    defaults = if names.last.is_a?(Hash)
      names.pop.map{ |k,v| [k.to_s, v] }.to_h
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
