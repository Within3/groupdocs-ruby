#GET request
get '/sample-27-how-to-create-your-own-questionnaire-using-forms-and-show-the-result-document' do
  haml :sample27
end

#POST request
post '/sample-27-how-to-create-your-own-questionnaire-using-forms-and-show-the-result-document' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:fileId]
  set :source, params[:source]
  set :sex, params[:sex]
  set :age, params[:age]
  set :sunrise, params[:sunrise]
  set :name, params[:name]
  set :type, params[:type]
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
        # Make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(file_path, {})
    when 'url'
        # Upload file from defined url
        file = GroupDocs::Storage::File.upload_web!(settings.url)
    else
        raise 'Wrong GUID source.'
    end

    #Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)

    #Make GroupDocs::Storage::Document instance
    document = file.to_document

    #Create datasource with fields
    datasource = GroupDocs::DataSource.new

    #Get arry of document's fields
    enteredData = {"sex" => settings.sex, "name" => settings.name, "age"=> settings.age, "sunrise" => settings.sunrise}

    #Create Field instance and fill the fields
    datasource.fields = enteredData.map { |key, value| GroupDocs::DataSource::Field.new(name: key, type: :text, values: Array.new() << value) }


    #Adds datasource.
    datasource.add!()

    #Creates new job to merge datasource into document.
    job = document.datasource!(datasource, {:new_type => settings.type})
    sleep 10 #Wait for merge and convert

    #Returns an hash of input and output documents associated to job.
    document = job.documents!()

    #Download file
    document[:inputs][0].outputs[0].download!(downloads_path)

    #Set converted document GUID
    guid = document[:inputs][0].outputs[0].guid

    #Set converted document Name
    file_name = document[:inputs][0].outputs[0].name

    #Prepare to sign url
    iframe = "/document-viewer/embed/#{guid}"
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

    #Set iframe with document GUID or raise an error
    if guid
      #Make iframe
      iframe = "<iframe id='downloadframe' src='#{iframe}' width='800' height='1000'></iframe>"
    else
      raise 'File was not converted'
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample27, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :sex => settings.sex,  :age => settings.age, :sunrise => settings.sunrise, :name => settings.name, :type => settings.type, :iframe => iframe, :file_name => file_name,  :err => err}
end