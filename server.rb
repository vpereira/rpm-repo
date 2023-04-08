# frozen_string_literal: true

require 'sinatra'
require 'net/http'

set :bind, '0.0.0.0'
set :port, 3000

# Set up the upstream repository URL
UPSTREAM_REPO_URL = 'http://download.opensuse.org/tumbleweed/repo/oss/'

# Set up the local cache directory
CACHE_DIR = '/var/www/html/repo'

# Ensure the cache directory exists
Dir.mkdir(CACHE_DIR) unless Dir.exist?(CACHE_DIR)

# Set up the Nginx server URL
NGINX_URL = 'http://localhost:80'

helpers do
  # Constructs the URL for the requested package in the upstream repository
  def package_url(package, version)
    "#{UPSTREAM_REPO_URL}/#{package}-#{version}.rpm"
  end

  # Constructs the local cache file path for the requested package
  def cache_file(package, version)
    File.join(CACHE_DIR, "#{package}-#{version}.rpm")
  end

  # Downloads the package from the upstream repository and caches it locally
  def download_package(package, version)
    package_uri = URI.parse(package_url(package, version))
    response = Net::HTTP.get_response(package_uri)

    raise "Package not found: #{package}-#{version}" unless response.code == '200'

    # If the package was downloaded successfully, cache it locally
    File.open(cache_file(package, version), 'wb') do |file|
      file.write(response.body)
    end
  end

  # Serve the package using Nginx
  def serve_package(package, version)
    redirect "#{NGINX_URL}/#{cache_file(package, version)}"
  end
end

# Route for handling package installation requests
get '/*' do
  # Extract the package name and version from the request URL
  package, version = params[:splat]

  # Check if the package is already in the local cache
  if File.exist?(cache_file(package, version))
    serve_package(package, version)
  else
    # If the package is not in the cache, download it from the upstream repository and cache it locally
    begin
      download_package(package, version)
      serve_package(package, version)
    rescue StandardError => e
      # If the package was not found in the upstream repository, return a 404 error
      status 404
      body e.message
    end
  end
end
