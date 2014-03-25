#GET request
get '/sample21' do
  haml :sample21
end

#POST request
post '/sample21/signature_callback' do
  #Set download path
  downloads_path = "#{File.dirname(__FILE__)}/../public/downloads"

  #Get callback request
  data = JSON.parse(request.body.read)
  begin
    raise 'Empty params!' if data.empty?
    source_id = nil
    client_id = nil
    private_key = nil

    #Get value of SourceId
    data.each do |key, value|
      if key == 'SourceId'
        source_id = value
      end
    end

    #Get private key and client_id from file user_info.txt
    if File.exist?("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = File.read("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = contents.split(' ')
      client_id = contents.first
      private_key = contents.last
    end

    #Create Job instance
    job = GroupDocs::Signature::Envelope.new({:id => source_id})

    #Get document by job id
    documents = job.documents!({}, {:client_id => client_id, :private_key => private_key})

    #Download converted file
    documents[0].file.download!(downloads_path, {:client_id => client_id, :private_key => private_key})

  rescue Exception => e
    err = e.message
  end
end


#GET request
get '/sample21/check' do

  #Check is there download directory
  unless File.directory?("#{File.dirname(__FILE__)}/../public/downloads")
    return 'Directory was not found.'
  end

  #Get file name from download directory
  name = nil
  Dir.entries("#{File.dirname(__FILE__)}/../public/downloads").each do |file|
    name = file if file != '.' && file != '..'
  end

  name
end

#GET request
get '/sample21/downloads/:filename' do |filename|
  #Send file with header to download it
  send_file "#{File.dirname(__FILE__)}/../public/downloads/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end

#POST request
post '/sample21' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :email, params[:email]
  set :name, params[:name]
  set :lastName, params[:lastName]
  set :fileId, params[:fileId]
  set :callback, params[:callback]
  set :base_path, params[:basePath]
  set :url, params[:url]
  set :source, params[:source]

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
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.email.empty? or settings.name.empty? or settings.lastName.empty?

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

    #Write client and private key to the file for callback job
    if settings.callback
      out_file = File.new("#{File.dirname(__FILE__)}/../public/user_info.txt", 'w')
      #White space is required
      out_file.write("#{settings.client_id} ")
      out_file.write("#{settings.private_key}")
      out_file.close
    end

    file = nil
    #Get document by file GUID
    case settings.source
      when 'guid'
        #Create instance of File
        file = GroupDocs::Storage::File.new({:guid => settings.fileId}).to_document.metadata!()
        file = file.last_view.document.file.to_document
      when 'local'
        #Construct path
        file_path = "#{Dir.tmpdir}/#{params[:file][:filename]}"

        #Open file
        File.open(file_path, 'wb') { |f| f.write(params[:file][:tempfile].read) }
        #Make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(file_path, {}).to_document
      when 'url'
        #Upload file from defined url
        file = GroupDocs::Storage::File.upload_web!(settings.url).to_document
      else
        raise 'Wrong GUID source.'
    end

    name = file.name
    #Create envelope using user id and entered by user name
    envelope = GroupDocs::Signature::Envelope.new
    envelope.name = file.name
    envelope.email_subject = 'Sing this!'
    envelope.create!({})

    #Add uploaded document to envelope
    envelope.add_document!(file, {})

    #Get role list for current user
    roles = GroupDocs::Signature::Role.get!({})

    #Create new recipient
    recipient = GroupDocs::Signature::Recipient.new
    recipient.email = settings.email
    recipient.first_name = settings.name
    recipient.last_name = settings.lastName
    recipient.role_id = roles.detect { |role| role.name == 'Signer' }.id

    #Add recipient to envelope
    recipient = envelope.add_recipient!(recipient)


    #Get document id
    document = envelope.documents!({})


    #Get field and add the location to field
    field = GroupDocs::Signature::Field.get!({}).detect { |f| f.type == :signature }
    field.location = {:location_x => 0.15, :location_y => 0.73, :location_w => 150, :location_h => 50, :page => 1}
    field.name = 'EMPLOYEE SIGNATURE'

    #Add field to envelope
    envelope.add_field!(field, document[0], recipient, {})


    #Send envelop
    envelope.send!({:callbackUrl => settings.callback})

    #Prepare to sign url
    iframe = "/signature2/signembed/#{envelope.id}/#{recipient.id}"
    #Construct result string
    url = GroupDocs::Api::Request.new(:path => iframe).prepare_and_sign_url
    #Generate iframe URL
    case base_path
      when 'https://stage-api-groupdocs.dynabic.com'
        iframe = "https://stage-api-groupdocs.dynabic.com#{url}"
      when 'https://dev-api-groupdocs.dynabic.com'
        iframe = "https://dev-apps.groupdocs.com#{url}"
      else
        iframe = "https://apps.groupdocs.com#{url}"
    end

    #Make iframe
    iframe = "<iframe id='downloadframe' src='#{iframe}' width='800' height='1000'></iframe>"
    #Create message
    message = "<p>File was uploaded to GroupDocs. Here you can see your <strong>#{name}</strong> file in the GroupDocs Embedded Viewer.</p>"
  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample21, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :email => settings.email, :name => settings.name, :lastName => settings.lastName, :iframe => iframe, :massage => message, :err => err, :callback => settings.callback,}
end
