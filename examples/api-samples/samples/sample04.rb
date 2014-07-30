#GET request
get '/sample-4-how-to-download-a-file-from-groupdocs-storage-using-the-storage-api' do
  haml :sample04
end

#POST request
post '/sample-4-how-to-download-a-file-from-groupdocs-storage-using-the-storage-api' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:fileId]
  set :url, params[:url]
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

    #Get file GUID
    file = GroupDocs::Storage::File.new({:guid => settings.file_id}).to_document

    #Obtaining all Metadata for file
    document = file.metadata!
    file = document.last_view.document.file
    #Download file
    dowloaded_file = file.download!("#{File.dirname(__FILE__)}/../public/downloads")
    unless dowloaded_file.empty?
      massage = "<font color='green'>File was downloaded to the <font color='blue'>#{dowloaded_file}</font> folder</font> <br />"
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample04, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :fileId => settings.file_id, :massage => massage, :err => err}
end
