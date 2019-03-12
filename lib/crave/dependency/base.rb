require_relative '../dependency'
require_relative 'options'
require 'open3'

class Crave::Dependency::Base
  class << self
    def option_names
      @option_names ||= ['where']
    end

    def option_names=(names)
      @option_names = names
    end
  end

  def self.options(*names)
    self.option_names += names.map(&:to_s)
  end

  attr_reader :options

  def initialize(options_hash = {})
    @options = Crave::Dependency::Options.class_factory(*self.class.option_names).new(options_hash)
  end
end
