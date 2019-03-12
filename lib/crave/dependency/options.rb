require_relative '../dependency'

class Crave::Dependency::Options
  attr_reader :options_hash

  def initialize(options_hash)
    @options_hash = options_hash.map do |key, value|
      [key.to_s, value]
    end.to_h
  end

  def self.class_factory(*named_options)
    named_options = named_options.dup.map(&:to_s)

    Class.new(self) do
      define_method(:named_options) { named_options }
    end
  end

  def method_missing(name, *args)
    name = name.to_s

    if named_options.include?(name)
      options_hash[name]
    elsif name.end_with?("=") && named_options.include?(name[0..-2]) && args.length == 1
      options_hash[name[0..-2]] = args.first
    end
  end

  def respond_to_missing?(name, include_private = false)
    named_options.include?(name.to_sym) || super
  end
end
