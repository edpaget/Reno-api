source 'https://rubygems.org'

gem 'rails', '3.2.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'rails-api'
gem 'rake'

gem 'pg'
gem 'thin'
gem 'foreigner'
gem 'immigrant'

gem 'resque', require: 'resque/server'
gem 'aws-sdk'

group :test do
  gem 'simplecov', :require => false
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
end

group :development do
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'growl'
  gem 'pry'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
