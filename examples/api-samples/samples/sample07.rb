#GET request
get '/sample07' do
  haml :sample07
end

#POST request
post '/sample07' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
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

    #Make a request to API using client_id and private_key
    files_list = GroupDocs::Storage::Folder.list!('/', {:extended => true}, {:client_id => settings.client_id, :private_key => settings.private_key})

    #Construct result string
    thumbnails = ''
    files_list.each do |element|
      if element.class.name.split('::').last == 'Folder'
        next
      end
      if element.thumbnail
        name = element.name
        thumbnails += "<img src='data:image/png;base64,#{element.thumbnail}', width='40px', height='40px'> #{name}"
      end
    end

    unless thumbnails.empty?
      set :thumbnails, thumbnails
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample07, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :thumbnailList => thumbnails, :err => err}
end
