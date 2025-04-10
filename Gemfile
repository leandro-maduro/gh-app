# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'jwt', '~> 2.10'
gem 'mission_control-jobs'
gem 'octokit', '~> 9.2'
gem 'pg'
gem 'propshaft'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.0.2'
gem 'solid_cache'
gem 'solid_queue'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop-rails-omakase', require: false
  gem 'rubocop-rspec', require: false
end
