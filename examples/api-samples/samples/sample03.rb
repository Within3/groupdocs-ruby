#GET request
get '/sample03' do
  haml :sample03
end

#POST request
post '/sample03' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :source, params[:source]
  set :url, params[:url]
  set :folder_path, params[:folderPath]
  set :callback, params[:callback]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty?

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

    #Get document by file GUID
    case settings.source

    when 'file'
      #Construct path
      filepath = "#{Dir.tmpdir}/#{params[:file][:filename]}"
      #Open file
      File.open(filepath, 'wb') { |f| f.write(params[:file][:tempfile].read) }
      #Make a request to API using client_id and private_key
      file = GroupDocs::Storage::File.upload!(filepath, {path: settings.folder_path, callbackUrl: settings.callback})

    when 'url'

      #Upload file from defined url
      file = GroupDocs::Storage::File.upload_web!(settings.url)
    else raise 'Wrong GUID source.'
    end

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

    #Set iframe with document GUID
    iframe = "<iframe src='#{iframe}' frameborder='0' width='720' height='600'></iframe>"

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample03, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :iframe => iframe, :err => err}
end
