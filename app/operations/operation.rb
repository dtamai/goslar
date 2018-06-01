# frozen_string_literal: true

class Operation
  attr_reader :response

  def initialize
    @response = {}
  end

  private

  def invalid_params!
    error! :invalid_params
    false
  end

  def result!(value)
    @response[:result] = value
  end

  def collect!(response)
    @response.merge! response
  end

  def ok?
    @response[:error].blank?
  end

  def error!(code)
    @response[:error] = code
  end
end
