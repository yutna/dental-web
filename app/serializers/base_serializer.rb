class BaseSerializer
  class << self
    def serialize(record)
      raise NotImplementedError, "#{name} must implement .serialize"
    end

    def serialize_collection(records)
      records.map { |r| serialize(r) }
    end
  end
end
