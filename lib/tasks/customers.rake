# frozen_string_literal: true

namespace :customers do
  desc "Create a new user"
  task create: :environment do
    customer = Customer.create
    puts "New customer id: #{customer.id}"
  end
end
