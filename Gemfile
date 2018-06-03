# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.5.1"

gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.11"
gem "rack-cors"
gem "rails", "~> 5.2.0"

gem "bootsnap", ">= 1.1.0", require: false

gem "multi_json"
gem "roar"
gem "tzinfo-data"

group :development, :test do
  gem "pry-byebug"
end

group :development do
  gem "rubocop"
  gem "rubocop-rspec"
end

group :test do
  gem "factory_bot_rails"
  gem "rspec-rails"
end
