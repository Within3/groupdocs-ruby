#GET request
get '/sample29' do
  haml :sample29
end

#POST request
post '/sample29' do

  #Set variables
  set :client_id, params[:clientId]
  set :base_path, params[:serverType]
  set :url, params[:url]

  url = settings.url
  base_path = settings.base_path
  client_id = settings.client_id

  begin

    #Prepare base path
    if settings.base_path.empty?
      base_path = 'https://api.groupdocs.com'
    elsif settings.base_path.match('/v2.0')
      base_path = settings.base_path.split('/v2.0')[0]
    end

    #Generate iframe url for chosen server
    if (!url.empty?)

      if (base_path == "https://api.groupdocs.com/v2.0")
        iframe = "https://apps.groupdocs.com/document-viewer/embed?url=#{url}&user_id=#{client_id}"
      elsif (base_path == "https://dev-api.groupdocs.com/v2.0")

        #iframe to dev server
        iframe = "https://dev-apps.groupdocs.com/document-viewer/embed?url=#{url}&user_id=#{client_id}"
      elsif (base_path == "https://stage-api.groupdocs.com/v2.0")

        #iframe to test server
        iframe = "https://stage-apps.groupdocs.com/document-viewer/embed?url=#{url}&user_id=#{client_id}"
      elsif (base_path == "http://realtime-api.groupdocs.com")
        iframe = "http://realtime-apps.groupdocs.com/document-viewer/embed?url=#{url}&user_id=#{client_id}"
      end


    end

  rescue Exception => e
    err = e.message
  end

  require 'json'
  content_type 'text/html'

  #Create json string with result data
  iframe = {:iframe => iframe, :error => ''}.to_json

end