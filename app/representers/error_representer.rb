# frozen_string_literal: true

class ErrorRepresenter < Roar::Decorator
  include Roar::JSON

  property :message
end
