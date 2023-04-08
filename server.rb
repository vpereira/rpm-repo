# frozen_string_literal: true

require 'sinatra'
require 'net/http'

set :bind, '0.0.0.0'
set :port, 3000

# Set up the upstream repository URL
upstream_repo_url = 'http://download.opensuse.org/tumbleweed/repo/oss/'

# Set up the local cache directory
cache_dir = '/var/www/html/repo'

# Ensure the cache directory exists
Dir.mkdir(cache_dir) unless Dir.exist?(cache_dir)

# Set up the Nginx server URL
nginx_url = 'http://localhost:80'

# Route for handling package installation requests
get '/*' do
  # Extract the package name and version from the request URL
  package = params[:splat].first
  version = params[:splat].last

  # Construct the URL for the requested package in the upstream repository
  package_url = "#{upstream_repo_url}/#{package}-#{version}.rpm"

  # Construct the local cache file path for the requested package
  cache_file = File.join(cache_dir, "#{package}-#{version}.rpm")

  # Check if the package is already in the local cache
  if File.exist?(cache_file)
    # If the package is in the cache, serve it using Nginx
    redirect "#{nginx_url}/#{cache_file}"
  else
    # If the package is not in the cache, download it from the upstream repository and cache it locally
    uri = URI.parse(package_url)
    response = Net::HTTP.get_response(uri)

    if response.code == '200'
      # If the package was downloaded successfully, cache it locally
      File.open(cache_file, 'wb') do |file|
        file.write(response.body)
      end

      # Serve the package using Nginx
      redirect "#{nginx_url}/#{cache_file}"
    else
      # If the package was not found in the upstream repository, return a 404 error
      status 404
      body "Package not found: #{package}-#{version}"
    end
  end
end
