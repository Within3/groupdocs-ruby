#GET request
get '/sample-5-how-to-copy-move-a-file-using-the-groupdocs-storage-api' do
  haml :sample05
end

#POST request
post '/sample-5-how-to-copy-move-a-file-using-the-groupdocs-storage-api' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:srcPath]
  set :url, params[:url]
  set :copy, params[:copy]
  set :move, params[:move]
  set :dest_path, params[:destPath]
  set :source, params[:source]
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
    #Get document by file GUID
    case settings.source
      when 'guid'
        file = GroupDocs::Storage::File.new({:guid => settings.file_id}).to_document.metadata!()
        file = file.last_view.document.file
      when 'local'
        #Construct path
        filepath = "#{Dir.tmpdir}/#{params[:file][:filename]}"
        #Open file
        File.open(filepath, 'wb') { |f| f.write(params[:file][:tempfile].read) }
        #Make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(filepath, {overrideMode: 3})
      when 'url'
        file = GroupDocs::Storage::File.upload_web!(settings.url)
      else
        raise 'Wrong GUID source.'
    end

    #Copy file using request to API
    unless settings.copy.nil?
      file = file.copy!(settings.dest_path, {})
      button = settings.copy
    end

    #Move file using request to API
    unless settings.move.nil?
      file = file.move!(settings.dest_path, {})
      button = settings.move
    end

    #Result message
    if file
      massage = "<h4><span style=\"color: green\">File was #{button}'ed to the <font color=\"blue\">#{settings.dest_path}</font> folder</span></h4>"
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample05, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :fileId => settings.file_id, :destPath => settings.dest_path, :massage => massage, :err => err}
end
