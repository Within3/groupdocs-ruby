#GET request
get '/sample34' do
  haml :sample34
end

#POST request
post '/sample34' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :path, params[:folder]
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
      # Optionally specify API server and version
      groupdocs.api_server = base_path # default is 'https://api.groupdocs.com'
    end

    #Create new Folder
    folder = GroupDocs::Storage::Folder.create!(settings.path)
    if folder.id
       message = "<span style=\"color:green\">Folder was created #{folder.path} </span> "
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample34, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :message => message, :err => err}
end
