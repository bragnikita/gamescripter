# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# gem "rails"
#

ruby '2.6.2'

gem 'sinatra'
gem 'sinatra-contrib'
gem "sinatra-cross_origin"
gem 'mongoid'
gem 'puma'
gem 'dotenv'
gem 'jwt'
gem 'gamescript_creator', git: 'https://github.com/bragnikita/gamescript_creator.git', branch: 'master'
group :test do
  gem 'rspec'
  gem 'rspec-json_expectations'
  gem 'rspec-collection_matchers'
  gem 'rack-test'
end
group :development do
  gem "capistrano", "~> 3.10", require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-bundler', '~> 1.5', require: false
end