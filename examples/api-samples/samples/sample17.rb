#GET request
get '/sample17' do
  haml :sample17
end

#POST request
post '/sample17' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file, params[:file]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.file.nil?

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

    #Construct path
    filepath = "#{Dir.tmpdir}/#{params[:file][:filename]}"
    #Open file
    File.open(filepath, 'wb') { |f| f.write(params[:file][:tempfile].read) }
    #Upload file
    file = GroupDocs::Storage::File.upload!(filepath, {})
    #Compress file
    file.compress!()

    #Construct result messages
    massage = "<p>Archive created and saved successfully. Here you can see your <strong>#{params[:file][:filename]}</strong> file in the GroupDocs Embedded Viewer.</p>"

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

  # set variables for template
  haml :sample17, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :iframe => iframe, :massage => massage, :err => err}
end
