require 'rspec'
require 'vcr_setup'
require 'rack/test'
require 'sinatra/base'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
