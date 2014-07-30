#GET request
get '/sample-33-how-to-convert-several-html-documents-into-one-pdf-document' do
  haml :sample33
end

#POST request
post '/sample-33-how-to-convert-several-html-documents-into-one-pdf-document' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :url_1, params[:url1]
  set :url_2, params[:url2]
  set :url_3, params[:url3]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.url_1.empty? or settings.url_2.empty? or settings.url_3.empty?

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


    #Create Array from variables
    url = [settings.url_1, settings.url_2, settings.url_3 ]

    #Create Hash with the options for job. :status=> -1 means the Draft status of the job
    options = {:actions => [:convert, :combine], :out_formats => ['pdf'], :status => -1, :name => 'sample'}

    #Create Job with provided options with Draft status (Sheduled job)
    job = GroupDocs::Job.create!(options)

    #Upload documents to GroupDocs Storage by url and add the documents to previously created Job
    url.each do |url|
      document = GroupDocs::Storage::File.upload_web!(url).to_document
      job.add_document!(document, {:check_ownership => false})
    end

    #Update the Job with new status. :status => '0' mean Active status of the job (Start the job)
    id = job.update!({:status => '0'})
    
	i = 1
    
    while i<5 do
      sleep(5)
      job = GroupDocs::Job.get!(id[:job_id])
      break if job.status == :archived
      i  = i + 1
    end

    #Get the document into Pdf format
    file = job.documents!()

    document = file[:outputs]

    #Set iframe with document GUID or raise an error
    if document

      #Prepare to sign url
      iframe = "/document-viewer/embed/#{document[0].guid}"
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

    else
      raise 'File was not converted'
    end
  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample33, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :err => err, :iframe => iframe}
end
