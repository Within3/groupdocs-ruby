# GET request
get '/sample31' do
  haml :sample31
end

# POST request
post '/sample31/callback' do
  # Set download path
  downloads_path = "#{File.dirname(__FILE__)}/../public/downloads"

  # Get callback request
  data = JSON.parse(request.body.read)
  begin
    raise 'Empty params!' if data.empty?
    source_id = nil
    client_id = nil
    private_key = nil

    # Get value of SourceId
    data.each do |key, value|
      if key == 'SourceId'
        source_id = value
      end
    end

    # Get private key and client_id from file user_info.txt
    if File.exist?("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = File.read("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = contents.split(' ')
      client_id = contents.first
      private_key = contents.last
    end

    # Create Job instance
    job = GroupDocs::Job.new({:id => source_id})

    # Get document by job id
    documents = job.documents!({:client_id => client_id, :private_key => private_key})

    # Download converted file
    documents[:inputs].first.outputs.first.download!(downloads_path, {:client_id => client_id, :private_key => private_key})

  rescue Exception => e
    err = e.message
  end
end


# GET request
get '/sample31/check' do

  # Check is there download directory
  unless File.directory?("#{File.dirname(__FILE__)}/../public/downloads")
    return 'Directory was not found.'
  end

  # Get file name from download directory
  name = nil
  Dir.entries("#{File.dirname(__FILE__)}/../public/downloads").each do |file|
    name = file if file != '.' && file != '..'
  end

  name
end

# GET request
get '/sample31/downloads/:filename' do |filename|
  # Send file with header to download it
  send_file "#{File.dirname(__FILE__)}/../public/downloads/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end


# POST request
post '/sample31' do
  # set variables
  set :client_id, params[:client_id]
  set :private_key, params[:private_key]
  set :template_guid, params[:template_guid]
  set :name, params[:name]
  set :country, params[:country]
  set :city, params[:city]
  set :street, params[:street]
  set :email, params[:email]
  set :callback, params[:callback]
  set :last_name, params[:last_name]

  # Set download path
  downloads_path = "#{File.dirname(__FILE__)}/../public/downloads"

  # Remove all files from download directory or create folder if it not there
  if File.directory?(downloads_path)
    Dir.foreach(downloads_path) { |f| fn = File.join(downloads_path, f); File.delete(fn) if f != '.' && f != '..' }
  else
    Dir::mkdir(downloads_path)
  end

  begin
    # check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty?

    # Write client and private key to the file for callback job
    if settings.callback[0]
      out_file = File.new("#{File.dirname(__FILE__)}/../public/user_info.txt", 'w')
      # white space is required
      out_file.write("#{settings.client_id} ")
      out_file.write("#{settings.private_key}")
      out_file.close
    end

    file = nil
    # Create instance of File
    file = GroupDocs::Storage::File.new({:guid => settings.template_guid})
    # Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)

    # Make GroupDocs::Storage::Document instance
    document = file.to_document

    # Create datasource with fields
    datasource = GroupDocs::DataSource.new

    # Get arry of document's fields
    enteredData = {"email" => settings.email, "name" => settings.name, "last_name" => settings.last_name, "country"=> settings.country, "city" => settings.city, "street" => settings.street}


    # Create Field instance and fill the fields
    datasource.fields = enteredData.map { |key, value| GroupDocs::DataSource::Field.new(name: key, type: :text, values: Array.new() << value) }

    # Adds datasource.
    datasource.add!({:client_id => settings.client_id, :private_key => settings.private_key})


    # Creates new job to merge datasource into document.
    job = document.datasource!(datasource, {:new_type => "pdf"}, {:client_id => settings.client_id, :private_key => settings.private_key})
    sleep 10 # wait for merge and convert

    # Returns an hash of input and output documents associated to job.
    jobInfo = job.documents!({:client_id => settings.client_id, :private_key => settings.private_key})

    # Creates new document to envelope
    document = jobInfo[:inputs][0].outputs[0].to_document

    # Creates envelope using user id and entered by user name
    envelope = GroupDocs::Signature::Envelope.new
    envelope.name = jobInfo[:inputs][0].outputs[0].name
    envelope.create!({}, {:client_id => settings.client_id, :private_key => settings.private_key})

    # Adds uploaded document to envelope
    envelope.add_document!(document, {}, {:client_id => settings.client_id, :private_key => settings.private_key})

    # Get role list for current user
    roles = GroupDocs::Signature::Role.get!({}, {client_id: settings.client_id, private_key: settings.private_key})

    # Creates new recipient
    recipient = GroupDocs::Signature::Recipient.new
    recipient.email = 'test@test.com'
    recipient.first_name = 'test'
    recipient.last_name = 'test'
    recipient.role_id = roles.detect { |role| role.name == 'Signer' }.id

    # Adds recipient to envelope
    envelope.add_recipient!(recipient, {client_id: settings.client_id, private_key: settings.private_key})

    #Get field
    fieldGet = GroupDocs::Signature::Field.get!({},{client_id: settings.client_id, private_key: settings.private_key}).detect { |f| f.type == :signature }
    fieldGet.location = { location_x: 0.15,
                          location_y: 0.73,
                          location_width: 150,
                          location_height: 50,
                          page: 1 }

    #Get document
    documentGet = envelope.documents!({}, {client_id: settings.client_id, private_key: settings.private_key}).first

    #Get recipients
    recipientGet = envelope.recipients!({},{client_id: settings.client_id, private_key: settings.private_key}).first

    # Add field to envelope
    addField = envelope.add_field!(fieldGet, documentGet, recipientGet, {}, {client_id: settings.client_id, private_key: settings.private_key})


    # Send envelope
    envelope.send!(settings.callback, {client_id: settings.client_id, private_key: settings.private_key})

    # Make iframe
    iframe = "<iframe src='https://apps.groupdocs.com/signature/signembed/#{envelope.id}/#{recipientGet.id}' frameborder='0' width='720' height='600'></iframe>"


  rescue Exception => e
    err = e.message
  end

  # set variables for template
  haml :sample31, :locals => {:userId => settings.client_id,
                              :privateKey => settings.private_key,
                              :callback => settings.callback,
                              :email => settings.email,
                              :name => settings.name,
                              :country => settings.country,
                              :city => settings.city,
                              :street => settings.street,
                              :iframe => iframe,
                              :err => err}
end