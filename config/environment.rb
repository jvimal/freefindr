# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
App::Application.initialize!

Geocoder::Configuration.api_key = ""
Geocoder::Configuration.lookup = :google
