require_relative '../dependency'

class Crave::Dependency::Options
  attr_reader :options_hash

  def initialize(options_hash)
    set_default_options

    options_hash.each do |key, value|
      set_or_prepend(key.to_s, value)
    end
  end

  def set_or_prepend(name, value)
    current_value = options_hash[name]

    if prepend?(name, value)
      options_hash[name] = [*Array(value), *options_hash[name]]
    else
      options_hash[name] = value
    end
  end

  def self.class_factory(named_options = [], default_options = {})
    default_options = default_options.map{ |k,v| [k.to_s, v] }.to_h
    named_options = named_options.dup.map(&:to_s) | default_options.keys

    Class.new(self) do
      define_method(:named_options) { named_options }
      define_method(:default_options) { default_options }
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

  private

  def prepend?(name, value)
    options_hash[name].is_a?(Array)
  end

  def set_default_options
    @options_hash ||= {}
    @options_hash = @options_hash.merge(default_options)
  end
end
