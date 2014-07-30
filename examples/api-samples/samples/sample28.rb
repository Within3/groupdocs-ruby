#GET request
get '/sample-28-how-to-delete-all-annotations-from-document' do
  haml :sample28
end

#POST request
post '/sample-28-how-to-delete-all-annotations-from-document' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:fileId]
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
      # Optionally specify API server and version
      groupdocs.api_server = base_path # default is 'https://api.groupdocs.com'
    end

    #Make a request to API using client_id and private_key
    files_list = GroupDocs::Storage::Folder.list!('/', {})
    document = ''

    #Get document by file ID
    files_list.each do |element|
      if element.respond_to?('guid') == true and element.guid == settings.file_id
        document = element
      end
    end

    document = GroupDocs::Storage::File.new(guid: settings.file_id)

    unless document.instance_of? String
      #Get list of annotations
      annotations = document.to_document.annotations!()

      #Delete all annotations from document
      annotations.each do |annotation|
          annotation.remove!()
      end

      #Prepare to sign url
      iframe = "/document-viewer/embed/#{settings.file_id}"
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

      message = 'Annotations was deleted from document'
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample28, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :messages => message, :iframe => iframe, :fileId => settings.file_id, :err => err}
end
