require 'active_support'
require 'sinatra'
require 'groupdocs'
require 'haml'
require 'pp'

GroupDocs.api_version = '2.0'

get '/' do
  haml :index
end

get '/style.css' do
  sass :style
end

Dir['samples/*.rb'].each {|file| require_relative file }

def partial(page, options={})
  haml page, options.merge!(:layout => false)
end