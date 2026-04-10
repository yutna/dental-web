module Dental
  class TypedId
    PREFIX = nil

    attr_reader :value

    def initialize(value)
      @value = normalize(value)
      validate!
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
      value.to_s.strip.upcase
    end

    def validate!
      raise ArgumentError, "#{self.class.name} cannot be blank" if value.blank?

      return if self.class::PREFIX.nil?
      return if value.start_with?(self.class::PREFIX)

      raise ArgumentError, "#{self.class.name} must start with #{self.class::PREFIX}"
    end
  end
end
