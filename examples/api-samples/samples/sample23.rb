#GET request
get '/sample-23-how-to-view-document-pages-as-images' do
  haml :sample23
end

#POST request
post '/sample-23-how-to-view-document-pages-as-images' do

  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :source, params[:source]
  set :file_id, params[:fileId]
  set :url, params[:url]
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
    when 'guid'
        #Create instance of File
        file = GroupDocs::Storage::File.new({:guid => settings.file_id})
    when 'local'
        #Construct path
        file_path = "#{Dir.tmpdir}/#{params[:file][:filename]}"
        #Open file
        File.open(file_path, 'wb') { |f| f.write(params[:file][:tempfile].read) }
        #Make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(file_path, {})
    when 'url'
        #Upload file from defined url
        file = GroupDocs::Storage::File.upload_web!(settings.url)
    else
        raise 'Wrong GUID source.'
    end

    #Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)

    #Make GroupDocs::Storage::Document instance
    document = file.to_document

    #Create new page
    page_image = document.page_images!(700, 700, {})

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample23,  :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :page_image => page_image, :err => err}
end
