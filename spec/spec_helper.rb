# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'simplecov'
SimpleCov.configure do
  add_filter('spec/')
  add_filter('vendor/')
end
SimpleCov.start

require 'webmock/rspec'
require 'groupdocs'

RSpec.configure do |spec|
  spec.before(:all) do
    GroupDocs.configure do |groupdocs|
      groupdocs.client_id = '07aaaf95f8eb33a4'
      groupdocs.private_key = '5cb711b3a52ffc5d90ee8a0f79206f5a'
      groupdocs.api_version = '2.0'
    end
  end
end

#
# Mocks GroupDocs::Api::Request.
#
def mock_api_request(path)
  subject.stub(options: {})
  subject.options.stub(:[]).with(:path).and_return(path.dup)
end

#
# Mocks RestClient::Resource.
#
def mock_resource(method)
  subject.resource.stub(:[]).with(subject.options[:path]).and_return(subject.resource)
  subject.resource[subject.options[:path]].stub(method.downcase).with(any_args).and_return(true)
end

#
# Mocks JSON response.
#
def mock_response(json)
  subject.stub(response: json)
end

#
# Mocks API server.
#
def mock_api_server(json, headers = {})
  request = stub_request(:any, /#{GroupDocs.api_server}.*/)
  request = request.with(headers: headers) unless headers.empty?
  request.to_return(body: json)
end

#
# Loads JSON file.
#
def load_json(name)
  File.read("spec/support/json/#{name}.json")
end
