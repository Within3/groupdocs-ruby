#GET request
get '/sample-2-how-to-list-files-within-groupdocs-storage-using-the-storage-api' do
  haml :sample02
end

#POST request
post '/sample-2-how-to-list-files-within-groupdocs-storage-using-the-storage-api' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :base_path, params[:basePath]

  begin

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

    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty?

    #Make a request to API using client_id and private_key
    files_list = GroupDocs::Storage::Folder.list!('/', {})

    #Construct list of files
    filelist = ''
    files_list.each do |element|
     if element.class.name.split('::').last == 'File' then filelist << "#{element.name}<br />" end
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample02, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :filelist => filelist, :err => err}
end
