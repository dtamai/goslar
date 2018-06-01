# frozen_string_literal: true

class Payload < ActiveRecord::Type::Value
  def type
    :jsonb
  end

  def cast(value)
    deserialize(value)
  end

  def deserialize(value)
    value = value.to_h.to_json unless value.is_a? String
    JSON.parse(value, object_class: OpenStruct)
  end

  def serialize(value)
    JSON.dump(value.as_json)
  end
end
