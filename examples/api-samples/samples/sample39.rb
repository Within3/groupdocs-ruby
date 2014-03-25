 #GET request
get '/sample39' do
  haml :sample39
end

 #GET request
get '/popup' do
  haml :popup
end

 #POST request
post '/sample39/signature_callback' do
  begin
     #Get callback request
    data = JSON.parse(request.body.read)

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
    documents = job.documents!({}, {:client_id => client_id, :private_key => private_key}).first

     #Get guid from file
    guid = documents.file.guid

     #Create new file callback_info.txt and write the guid document
    out_file = File.new("#{File.dirname(__FILE__)}/../public/callback_info.txt", 'w')
     #White space is required
    out_file.write("#{guid}")
    out_file.close

  rescue Exception => e
    err = e.message
  end
end

 #POST request
post '/sample39/check' do
  begin
    result = nil
    i = 0
    for i in 1..10
      i +=1

       #Check is downloads folder exist
      if File.exist?("#{File.dirname(__FILE__)}/../public/callback_info.txt")
        result = File.read("#{File.dirname(__FILE__)}/../public/callback_info.txt")
        if result.nil? then break  end
      end
      sleep(5)
    end

    #Check result
    if result == 'Error'
      result = "File was not found. Looks like something went wrong."
    else
      result
    end

  rescue Exception => e
    err = e.message
  end
end


#POST request
post '/sample39/postdata' do

  data = request.body.read
   #Decode ajax data
  json_post_data = JSON.parse(data);
   #Get Client ID
  clientId = json_post_data['userId'];
   #Get Private Key
  privateKey = json_post_data['privateKey'];
   #Get document for sign
  documents = json_post_data['documents'];
   #Get signature file
  signers = json_post_data['signers'];

   #Documents local path
  document_path = "#{File.dirname(__FILE__)}/../public/downloads/#{documents[0]['name']}"
  signer_path = "#{File.dirname(__FILE__)}/../public/downloads/#{signers[0]['name']}.png"

   #Get base64 string
  base64_documents = documents[0]['data'].split(',').last
  base64_signers = signers[0]['data'].split(',').last

   #Write to the files decode base64 strings
  File.open(document_path, 'wb') do |f|
    f.write(Base64.strict_decode64(base64_documents))
  end

  File.open(signer_path, 'wb') do |f|
    f.write(Base64.strict_decode64(base64_signers))
  end

   #Set document for signing
  documents = GroupDocs::Storage::File.new(:name=>documents[0]['name'], :local_path=>document_path).to_document
   #Set signature
  signers = GroupDocs::Signature.new(:name=>signers[0]['name'], :image_path=>signer_path)
  signers.position = {top: 0.83319, left: 0.72171, width: 100, height: 40}

   #Make request to sign documnet
  signDocument = GroupDocs::Document.sign_documents!([documents], [signers], {}, {:client_id=>clientId, :private_key=>privateKey})
  sleep(5)
   #Get the document guid
  document = GroupDocs::Signature.sign_document_status!(signDocument, {:client_id=>clientId, :private_key=>privateKey})
   #Get file GUID
  guid = document.guid
   #Create array with result data
  result = ['guid' => guid,'clientId' => clientId,'privateKey' => privateKey]
   #Decode array to json and return json string to ajax request
  result.to_json
end


#POST request
post '/sample39' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :name, params[:name]
  set :email, params[:email]
  set :callback, params[:callbackUrl]
  set :last_name, params[:lastName]
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
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.name.empty? or settings.email.empty? or settings.last_name.empty?

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
      groupdocs.api_server = base_path #Default is 'https://api.groupdocs.com'

    end

     #Write client and private key to the file for callback job
    if settings.callback[0]
      out_file = File.new("#{File.dirname(__FILE__)}/../public/user_info.txt", 'w')
       #White space is required
      out_file.write("#{settings.client_id} ")
      out_file.write("#{settings.private_key}")
      out_file.close
    end

     #Construct path
    file_path = "#{Dir.tmpdir}/#{params[:file][:filename]}"
     #Open file
    File.open(file_path, 'wb') { |f| f.write(params[:file][:tempfile].read) }
     #Make a request to API using client_id and private_key
    file = GroupDocs::Storage::File.upload!(file_path)
    document = file.to_document


    #Create envelope using user id and entered by user name
    envelope = GroupDocs::Signature::Envelope.new
    envelope.name = file.name
    envelope.email_subject = 'Sing this!'
    envelope.create!

    #Add uploaded document to envelope
    envelope.add_document!(document)

    #Get role list for current user
    roles = GroupDocs::Signature::Role.get!

    #Create new recipient
    recipient = GroupDocs::Signature::Recipient.new
    recipient.email = settings.email
    recipient.first_name = settings.name
    recipient.last_name = settings.last_name
    recipient.role_id = roles.detect { |role| role.name == 'Signer' }.id

    #Add recipient to envelope
    recipient = envelope.add_recipient!(recipient)

    #Get document id
    document = envelope.documents!()

    # Get field and add the location to field
    field = GroupDocs::Signature::Field.get!().detect { |f| f.type == :signature }
    field.location = {:location_x => 0.15, :location_y => 0.73, :location_w => 150, :location_h => 50, :page => 1}
    field.name = 'EMPLOYEE SIGNATURE'

    #Add field to envelope
    envelope.add_field!(field, document[0], recipient, {})


    #Send envelop
    envelope.send!({:callbackUrl => settings.callback})

    #Prepare to sign url
    iframe = "/signature2/signembed/#{envelope.id}/#{recipient.id}"
    # Construct result string
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


  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample39, :locals => {:userId => settings.client_id,
                              :privateKey => settings.private_key,
                              :callback => settings.callback,
                              :email => settings.email,
                              :name => settings.name,
                              :lastName => settings.last_name,
                              :iframe => iframe,
                              :err => err}
end

