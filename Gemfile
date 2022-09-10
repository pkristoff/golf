# frozen_string_literal: true

source 'https://rubygems.org'
# git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'
# gem 'bundler', '~> 2.3.22'
gem 'bootstrap'
gem 'caxlsx'
gem 'jquery-rails'
gem 'net-smtp'
gem 'pg'
gem 'psych', '~> 3.3.01'
gem 'rails', '6.1.6.1'
# gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
# Use Puma as the app server
gem 'puma'
gem 'roo', '~> 2.8.0'
# Use SCSS for stylesheets
gem 'sass-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', require: false
  gem 'rubocop-publicdoc2', '~>0.1.4', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'database_cleaner'
  gem 'i18n-tasks'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

# begin not sure if need

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :test do
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

group :development do
  gem 'listen', '~> 3.2'
  # hook with inspector in chrome - currently not working
  gem 'meta_request'
end

# end not sure if need
