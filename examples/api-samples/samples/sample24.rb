#GET request
get '/sample-24-how-to-use-storageapi-to-upload-fil-from-url-to-groupdocs-account' do
  haml :sample24
end

#POST request
post '/sample-24-how-to-use-storageapi-to-upload-fil-from-url-to-groupdocs-account' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :url, params[:url]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.url.nil?

    #Prepare base path
    if settings.base_path.empty?
      base_path = 'https://api.groupdocs.com'
    elsif settings.base_path.match('/v2.0')
      base_path = settings.base_path.split('/v2.0')[0]
    else
      base_path = settings.base_path
    end

    #Configure your access to API server
    GroupDocs.configure do |groupdocs|
      groupdocs.client_id = settings.client_id
      groupdocs.private_key = settings.private_key
      #Optionally specify API server and version
      groupdocs.api_server = base_path # default is 'https://api.groupdocs.com'
    end

    #Upload web file
    file = GroupDocs::Storage::File.upload_web!(settings.url, {:client_id => settings.client_id, :private_key => settings.private_key})

    #Construct result messages
    message = "<p>File was uploaded to GroupDocs. Here you can see your <strong> file in the GroupDocs Embedded Viewer.</p>"

    #Prepare to sign url
    iframe = "/document-viewer/embed/#{file.guid}"
    # Construct result string
    url = GroupDocs::Api::Request.new(:path => iframe).prepare_and_sign_url
    #Generate iframe URL
    case base_path
      when 'https://stage-api-groupdocs.dynabic.com'
        iframe = "https://stage-api-groupdocs.dynabic.com#{url}"
      when 'https://dev-api-groupdocs.dynabic.com'
        iframe = "https://dev-apps.groupdocs.com#{url}"
      else
        iframe = "https://apps.groupdocs.com#{url}"
    end

    #Make iframe
    iframe = "<iframe id='downloadframe' src='#{iframe}' width='800' height='1000'></iframe>"

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample24, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :iframe => iframe, :message => message, :err => err}
end
