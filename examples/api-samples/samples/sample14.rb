#GET request
get '/sample-14-how-to-check-the-list-of-shares-for-a-folder' do
  haml :sample14
end

#POST request
post '/sample-14-how-to-check-the-list-of-shares-for-a-folder' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :folder, params[:path]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.folder.empty?

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
    folder = nil
    #Make a request to API using client_id and private_key
    files_list = GroupDocs::Storage::Folder.list!()

    files_list.map do |e|
      if e.name == settings.folder
        folder = e
      end
    end

    #Get list of shares for a folder
    shares = folder.sharers!()

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample14, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :folder => settings.folder, :shares => shares, :err => err}
end