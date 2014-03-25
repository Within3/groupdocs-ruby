#GET request
get '/sample08' do
  haml :sample08
end

#POST request
post '/sample08' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :guid, params[:guid]
  set :page_number, params[:pageNumber]
  set :source, params[:source]
  set :file_id, params[:fileId]
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

    file = nil
    doc = nil
    metadata = nil

    #Get document by file GUID
    case settings.source
      when 'guid'
        file = GroupDocs::Storage::File.new({:guid => settings.file_id})
      when 'local'
        #Construct path
        filepath = "#{Dir.tmpdir}/#{params[:file][:filename]}"
        #Open file
        File.open(filepath, 'wb') { |f| f.write(params[:file][:tempfile].read) }
        #Make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(filepath, {})
      when 'url'
        file = GroupDocs::Storage::File.upload_web!(settings.url)
      else
        raise 'Wrong GUID source.'
    end

    doc = file.to_document
    metadata = doc.metadata!()

    #Get document page images
    images = doc.page_images!(800, 400, {:first_page => 0, :page_count => metadata.views_count})

    #Result
    unless images.empty?
      image = images[Integer(settings.page_number)]
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample08, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :guid => settings.guid, :pageNumber => settings.page_number, :image => image, :err => err}
end
