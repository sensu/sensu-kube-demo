#!/usr/bin/env ruby
#

require "json"
require 'net/http'
require 'uri'

# Load the Sensu event data from STDIN
event = JSON.parse(STDIN.read, :symbolize_names => true)

sensu_api_client_url = "http://127.0.0.1:4567/clients/#{event[:client][:name]}"
uri = URI.parse(sensu_api_client_url)
request = Net::HTTP::Delete.new(uri)

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

# response.code
# response.body
