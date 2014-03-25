#GET request
get '/sample12' do
  haml :sample12
end

#POST request
post '/sample12' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:fileId]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.file_id.empty?

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

    #Create document object
    document = GroupDocs::Storage::File.new(guid: settings.file_id)
    unless document.instance_of? String
      #Get list of annotations
      annotations = document.to_document.annotations!()
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample12, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :annotations => annotations, :fileId => settings.file_id, :err => err}
end
