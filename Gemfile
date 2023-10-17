source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.6.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'

gem 'bootstrap-typeahead-rails'

gem 'carrierwave'
gem "aws-sdk-s3", require: false

# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'mini_magick'

gem 'materialize-sass', '~> 1.0.0.rc1'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'jwt'
gem 'friendly_id'
gem "breadcrumbs_on_rails"
gem 'mollie-api-ruby'
gem 'devise-i18n'
gem 'activeadmin_addons'
gem 'ahoy_matey', '~> 3.0'
gem 'starrr'
gem 'premailer-rails'
gem 'bootstrap-email'
gem 'fast_jsonapi'
gem 'pagy'
gem 'i18n-js', '~> 3.6'
# gem 'oj'
gem 'typhoeus'
gem 'redis-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'dotenv-rails'
  # gem 'pry'
  # gem 'pry-rails'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 4.0.2'
  gem 'selenium-webdriver'
end

group :production do
  gem 'exception_notification'
end

# group :staging do
#   gem 'exception_notification'
# end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano',          require: false
  gem 'capistrano-rbenv',    require: false
  gem 'capistrano-rails',    require: false
  gem 'capistrano-bundler',  require: false
  gem 'capistrano3-puma',    require: false
  gem 'capistrano-db-tasks', require: false
  gem 'bullet'
  gem 'rb-readline'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'bootstrap4-kaminari-views'
gem 'devise', '~> 4.4'
gem 'devise_invitable'
gem 'devise-bootstrapped'
# /, github: 'excid3/devise-bootstrapped', branch: 'bootstrap4'
gem 'jquery-rails', '~> 4.3.1'
gem 'bootstrap', '~> 4.0.0.beta'
gem 'webpacker', '~> 3.5'
gem 'sidekiq', '~> 5.0'
gem 'foreman', '~> 0.84.0'

gem 'jquery-ui-rails'

gem 'geocoder'
gem 'searchkick'
# gem 'elasticsearch', '8.0.1'
gem 'elasticsearch', '~> 7.0'
gem 'activeadmin'
gem 'route_translator'
gem 'globalize'
gem 'globalize-accessors'
gem 'chosen-rails'
# gem 'skylight', '3.1.2'
gem 'omniauth-google-oauth2'
gem 'omniauth-instagram'
gem 'omniauth-facebook'
gem 'arctic_admin'
gem "chartkick"
gem 'groupdate'
gem 'activerecord-import', '~> 0.15.0'
gem 'newrelic_rpm', '5.0.0.342'
gem 'rack-cors'
gem 'rack', '~> 2.0.9'
gem 'sinatra'
gem 'ox', '~> 2.13', '>= 2.13.3'
gem 'csv'
gem "recaptcha"
gem 'pg_lock'
gem 'pry'
gem 'pry-rails'
gem 'sidekiq-status'
