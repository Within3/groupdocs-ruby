#GET request
get '/sample30' do
  haml :sample30
end

#POST request
post '/sample30' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :name, params[:fileName]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.name.empty?

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

    #Make a request to API using client_id and private_key
    files_list = GroupDocs::Storage::Folder.list!('/', {})
    document = ''

    #Get document by file ID
    files_list.each do |element|
      if element.respond_to?('name') == true and element.name == settings.name
        document = element
      end
    end


    #Delete file from GroupDocs Storage
    document.delete!()

    message = 'Done, file deleted from your GroupDocs Storage'

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample30, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :message => message, :name => settings.name, :err => err}
end
