#!/usr/bin/env ruby
#
# A simple example handler plugin.

require "json"
require "rest-client"

# Load the Sensu event data from STDIN
event                     = JSON.parse(STDIN.read, :symbolize_names => true)

# Load the Kubernetes API credentials, from the Pod environment
kubernetes_service_host   = ENV["KUBERNETES_SERVICE_HOST"]
kubernetes_service_port   = ENV["KUBERNETES_SERVICE_PORT"]
kubernetes_namespace      = File.open("/var/run/secrets/kubernetes.io/serviceaccount/namespace", "rb").read
kubernetes_service_token  = File.open("/var/run/secrets/kubernetes.io/serviceaccount/token", "rb").read
kubernetes_service_cert   = File.open("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt", "rb").read

# Set the API endpoint details
kubernetes_api_protocol   = "https"
kubernetes_api_host       = kubernetes_service_host
kubernetes_api_port       = kubernetes_service_port
kubernetes_api_base_url   = "#{kubernetes_api_protocol}://#{kubernetes_api_host}:#{kubernetes_api_port}"
kubernetes_api_endpoint   = "/api/v1/namespaces/#{kubernetes_namespace}/pods/#{event[:client][:name]}"
kubernetes_api_url        = "#{kubernetes_api_base_url}#{kubernetes_api_endpoint}"

# Read the incoming JSON data from STDIN.

begin
  pod_status = JSON.parse(
    RestClient::Request.execute(
      method: :get,
      url: kubernetes_api_url,
      headers: {"Authorization":"Bearer #{kubernetes_service_token}"},
      ssl_ca_file: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"),
    :symbolize_names => true)

  if pod_status.has_key?(:status)
    puts pod_status[:status]
  end
rescue RestClient::ExceptionWithResponse => e
  sensu_api_client_url = "http://127.0.0.1:4567/clients/#{event[:client][:name]}"
  response = RestClient.delete( sensu_api_client_url )
  puts response
end
