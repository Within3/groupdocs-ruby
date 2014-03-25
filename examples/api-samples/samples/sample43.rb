#GET request
get '/sample43' do
  haml :sample43
end

#POST request
post '/sample43' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :source, params[:source]
  set :file_id, params[:fileId]
  set :url, params[:url]
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
        #Make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(file_path, {})
      when 'url'
        #Upload file from defined url
        file = GroupDocs::Storage::File.upload_web!(settings.url)
      else
        raise 'Wrong GUID source.'
    end

    #Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)

    #Make GroupDocs::Storage::Document instance
    document = file.to_document

    #Create Hash with the options for job. :status=> -1 means the Draft status of the job
    options = {:actions => [:convert, :number_lines], :out_formats => ['doc'], :name => 'sample'}

    #Create Job with provided options with Draft status (Sheduled job)
    job = GroupDocs::Job.create!(options)

    #Add the documents to previously created Job
    job.add_document!(document, {:check_ownership => false})


    #Update the Job with new status. :status => '0' mean Active status of the job (Start the job)
    id = job.update!({:status => 'pending'})

    i = 1

    while i<5 do
      sleep(5)
      job = GroupDocs::Job.get!(id[:job_id])
      break if job.status == :archived
      i  = i + 1
    end

    #Get the document into Pdf format
    file = job.documents!()

    document = file[:inputs][0].outputs[0]

    #Set iframe with document GUID or raise an error
    if document

      #Add the signature in url
      iframe = "/document-viewer/embed/#{document.guid}"
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

      iframe = "<iframe width='100%' height='600' id='downloadframe' frameborder='0' src='#{iframe}'></iframe>"
    else
      raise 'File was not converted'
    end
  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample43, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :err => err, :iframe => iframe}
end
