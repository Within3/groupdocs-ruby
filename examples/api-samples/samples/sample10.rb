#GET request
get '/sample10' do
  haml :sample10
end

#POST request
post '/sample10' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :guid, params[:fileId]
  set :email, params[:email]
  set :source, params[:source]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.guid.empty? or settings.email.empty?


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
    file = nil
    case settings.source
      when 'guid'
        file = GroupDocs::Storage::File.new({:guid => settings.guid}).to_document.metadata!()
        file = file.last_view.document.file
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

    #Share document. Make a request to API using client_id and private_key
    shared = file.to_document.sharers_set!(settings.email.split(' '))

    #Result
    if shared
      shared_emails = settings.email
    end
  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample10, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :guid => settings.guid, :email => settings.email, :shared => shared_emails, :err => err}
end
