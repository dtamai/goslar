# frozen_string_literal: true

require "roar/json"

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: ErrorRepresenter.new(exception), status: :not_found
  end

  attr_reader :customer_id

  def authenticate_customer
    @customer_id = request.headers[:authorization]

    head :unauthorized if customer_id.blank?
  end
end
