#GET request
get '/sample36' do
  haml :sample36
end

#POST request
post '/sample36' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :envelope, params[:envelopeGuid]
  set :base_path, params[:basePath]

  #Set download path
  downloads_path = "#{File.dirname(__FILE__)}/../public/downloads"

  #Remove all files from download directory or create folder if it not there
  if File.directory?(downloads_path)
    Dir.foreach(downloads_path) { |f| fn = File.join(downloads_path, f); File.delete(fn) if f != '.' && f != '..' }
  else
    Dir::mkdir(downloads_path)
  end


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

    #Get envelope from GroupDocs Storage
    envelope = GroupDocs::Signature::Envelope.get!(settings.envelope)

    #Download signed files
    path = envelope.signed_documents!(downloads_path)

    #Get file name
    file = path.split('/').last

    message = "<span style=\"color:green\">Files from the envelope were downloaded to server's local folder. You can check them <a href=\"/downloads/#{file}\">here</a></span>"
  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample36, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :envelopeGuid => settings.envelope, :message => message, :err => err}
end
