module Dental
  class EnumValue
    attr_reader :value

    def self.values
      allowed_values
    end

    def initialize(value)
      @value = normalize(value)
      return if self.class.allowed_values.include?(@value)

      raise ArgumentError, "#{self.class.name} must be one of: #{self.class.allowed_values.join(', ')}"
    end

    def ==(other)
      other.is_a?(self.class) && other.value == value
    end

    alias eql? ==

    def hash
      [ self.class.name, value ].hash
    end

    def to_s
      value
    end

    private

    def normalize(value)
      value.to_s.strip.downcase
    end
  end
end
