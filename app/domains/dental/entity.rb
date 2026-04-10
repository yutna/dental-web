module Dental
  class Entity
    attr_reader :id

    def initialize(id:)
      @id = id.is_a?(Dental::TypedId) ? id : Dental::TypedId.new(id)
    end

    def ==(other)
      other.is_a?(self.class) && other.id == id
    end

    alias eql? ==

    def hash
      [ self.class.name, id ].hash
    end
  end
end
