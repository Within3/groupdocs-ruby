#GET request
get '/sample-44-how-to-assemble-document-and-add-multiple-signatures-and-signers-to-a-document' do
  haml :sample44
end

#POST request
post '/sample-44-how-to-assemble-document-and-add-multiple-signatures-and-signers-to-a-document' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:fileId]
  set :first_name, params[:firstName]
  set :last_name, params[:lastName]
  set :first_email, params[:firstEmail]
  set :second_email, params[:secondEmail]
  set :gender, params[:gender]
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
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.first_email.empty? or settings.second_email.empty? or settings.first_name.empty?

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

    (settings.last_name.nil? or settings.last_name.empty?) ? settings.last_name = settings.first_name : settings.last_name

    second_signer_name = settings.first_name + "2"
    second_signer_last_name = settings.last_name + "2"
    #Construct path

    file_path = "#{Dir.tmpdir}/#{params[:file][:filename]}"
    #Open file
    File.open(file_path, 'wb') { |f| f.write(params[:file][:tempfile].read) }
    # Make a request to API using client_id and private_key
    file = GroupDocs::Storage::File.upload!(file_path, {})

    #Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)

    #Make GroupDocs::Storage::Document instance
    document = file.to_document

    #Create datasource with fields
    datasource = GroupDocs::DataSource.new

    #Get arry of document's fields
    enteredData = {"name" => settings.first_name, "gender" => settings.gender}

    #Create Field instance and fill the fields
    datasource.fields = enteredData.map { |key, value| GroupDocs::DataSource::Field.new(name: key, type: :text, values: Array.new() << value) }


    #Adds datasource.
    datasource.add!()

    #Creates new job to merge datasource into document.
    job = document.datasource!(datasource)
    sleep 10 #Wait for merge and convert

    #Returns an hash of input and output documents associated to job.
    document = job.documents!()

    #Set converted document GUID
    guid = document[:inputs][0].outputs[0].guid
    file = GroupDocs::Storage::File.new({:guid => guid})

    #Set converted document Name
    file_name = document[:inputs][0].outputs[0].name

    #Create envelope using user id and entered by user name
    envelope = GroupDocs::Signature::Envelope.new
    envelope.name = file_name
    envelope.create!({})

    #Add uploaded document to envelope
    envelope.add_document!(file.to_document, {})

    #Get role list for current user
    roles = GroupDocs::Signature::Role.get!({})

    #Create new first recipient
    first_recipient = GroupDocs::Signature::Recipient.new
    first_recipient.email = settings.first_email
    first_recipient.first_name = settings.first_name
    first_recipient.last_name = settings.last_name
    first_recipient.role_id = roles.detect { |role| role.name == 'Signer' }.id

    #Create new second recipient
    second_recipient = GroupDocs::Signature::Recipient.new
    second_recipient.email = settings.second_email
    second_recipient.first_name = second_signer_name
    second_recipient.last_name = second_signer_last_name
    second_recipient.role_id = roles.detect { |role| role.name == 'Signer' }.id

    #Add first recipient to envelope
    first_recipient = envelope.add_recipient!(first_recipient)

    #Add second recipient to envelope
    second_recipient = envelope.add_recipient!(second_recipient)

    #Get document id
    document = envelope.documents!({})


    #Get field and add the location to field
    field1 = GroupDocs::Signature::Field.get!({}).detect { |f| f.type == :signature }
    field1.location = {:location_x => 0.15, :location_y => 0.23, :location_w => 150, :location_h => 50, :page => 1}
    field1.name = 'singlIndex1'

    #Add field to envelope
    envelope.add_field!(field1, document[0], first_recipient, {})

    #Get field and add the location to field
    field2 = GroupDocs::Signature::Field.get!({}).detect { |f| f.type == :signature }
    field2.location = {:location_x => 0.35, :location_y => 0.23, :location_w => 150, :location_h => 50, :page => 1}
    field2.name = 'singlIndex2'

    #Add field to envelope
    envelope.add_field!(field2, document[0], second_recipient, {})

    #Send envelop
    envelope.send!()

    #Prepare to sign first url
    first_iframe = "/signature2/signembed/#{envelope.id}/#{first_recipient.id}"
    #Construct result string
    first_url = GroupDocs::Api::Request.new(:path => first_iframe).prepare_and_sign_url

    #Prepare to sign second url
    second_iframe = "/signature2/signembed/#{envelope.id}/#{second_recipient.id}"
    #Construct result string
    second_url = GroupDocs::Api::Request.new(:path => second_iframe).prepare_and_sign_url

    #Generate iframes URL
    case base_path
      when 'https://stage-api-groupdocs.dynabic.com'
        first_iframe = "https://stage-api-groupdocs.dynabic.com#{first_url}"
        second_iframe = "https://stage-api-groupdocs.dynabic.com#{second_url}"
      when 'https://dev-api-groupdocs.dynabic.com'
        first_iframe = "https://dev-apps.groupdocs.com#{first_url}"
        second_iframe = "https://dev-apps.groupdocs.com#{second_url}"
      else
        first_iframe = "https://apps.groupdocs.com#{first_url}"
        second_iframe = "https://apps.groupdocs.com#{second_url}"
    end

    #Set iframe with document GUID or raise an error
    if guid
      #Make first iframe
      first_iframe = "<p><span style=\"color: green\">Document for first signer</span></p><iframe id='downloadframe' src='#{first_iframe}' width='800' height='1000'></iframe><br>"
      #Make second iframe
      second_iframe = "<p><span style=\"color: green\">Document for second signer</span></p><iframe id='downloadframe' src='#{second_iframe}' width='800' height='1000'></iframe>"
    else
      raise 'File was not converted'
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample44, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :first_iframe => first_iframe, :second_iframe => second_iframe,  :err => err}
end