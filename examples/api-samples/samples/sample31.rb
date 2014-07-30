#GET request
get '/sample-31-how-to-dynamically-create-signature-form-using-data-from-html-form' do
  haml :sample31
end

#POST request
post '/sample31/callback' do
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
    job = GroupDocs::Job.new({:id => source_id})

    #Get document by job id
    documents = job.documents!({:client_id => client_id, :private_key => private_key})

    #Download converted file
    documents[:inputs].first.outputs.first.download!(downloads_path, {:client_id => client_id, :private_key => private_key})

  rescue Exception => e
    err = e.message
  end
end


#GET request
get '/sample31/check' do

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
get '/sample31/downloads/:filename' do |filename|
  #Send file with header to download it
  send_file "#{File.dirname(__FILE__)}/../public/downloads/#{filename}", :filename => filename, :type => 'Application/octet-stream'
end


#POST request
post '/sample-31-how-to-dynamically-create-signature-form-using-data-from-html-form' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :template_guid, params[:templateGuid]
  set :name, params[:name]
  set :country, params[:country]
  set :city, params[:city]
  set :street, params[:street]
  set :email, params[:email]
  set :callback, params[:callback]
  set :last_name, params[:lastName]
  set :base_path, params[:basePath]

  # Set download path
  downloads_path = "#{File.dirname(__FILE__)}/../public/downloads"

  # Remove all files from download directory or create folder if it not there
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

    #Write client and private key to the file for callback job
    if settings.callback[0]
      out_file = File.new("#{File.dirname(__FILE__)}/../public/user_info.txt", 'w')
      #White space is required
      out_file.write("#{settings.client_id} ")
      out_file.write("#{settings.private_key}")
      out_file.close
    end

    file = nil
    #Create instance of File
    file = GroupDocs::Storage::File.new({:guid => settings.template_guid})
    #Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)

    #Make GroupDocs::Storage::Document instance
    document = file.to_document

    #Create datasource with fields
    datasource = GroupDocs::DataSource.new

    #Get arry of document's fields
    enteredData = {"email" => settings.email, "name" => settings.name, "country"=> settings.country, "city" => settings.city, "street" => settings.street}


    #Create Field instance and fill the fields
    datasource.fields = enteredData.map { |key, value| GroupDocs::DataSource::Field.new(name: key, type: :text, values: Array.new() << value) }

    #Adds datasource.
    datasource.add!()


    #Creates new job to merge datasource into document.
    job = document.datasource!(datasource, {:new_type => "pdf"})
    sleep 10 # wait for merge and convert

    #Returns an hash of input and output documents associated to job.
    jobInfo = job.documents!()

    #Creates new document to envelope
    document = jobInfo[:inputs][0].outputs[0].to_document

    #Creates envelope using user id and entered by user name
    envelope = GroupDocs::Signature::Envelope.new
    envelope.name = jobInfo[:inputs][0].outputs[0].name
    envelope.create!({})

    #Adds uploaded document to envelope
    envelope.add_document!(document, {parseFields: true})

    #Get role list for current user
    roles = GroupDocs::Signature::Role.get!({})

    #Creates new recipient
    recipient = GroupDocs::Signature::Recipient.new
    recipient.email = settings.email
    recipient.first_name = settings.name
    recipient.last_name = "lastName"
    recipient.role_id = roles.detect { |role| role.name == 'Signer' }.id

    #Adds recipient to envelope
    envelope.add_recipient!(recipient)
    #Get recipients
    recipientGet = envelope.recipients!({}).first

    #Send envelope
    envelope.send!({:callbackUrl => settings.callback})

    #Prepare to sign url
    iframe = "/signature2/signembed/#{envelope.id}/#{recipientGet.id}"
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
  haml :sample31, :locals => {:userId => settings.client_id,
                              :privateKey => settings.private_key,
                              :callback => settings.callback,
                              :email => settings.email,
                              :name => settings.name,
                              :country => settings.country,
                              :city => settings.city,
                              :street => settings.street,
                              :iframe => iframe,
                              :templateGuid => settings.template_guid,
                              :err => err}
end
