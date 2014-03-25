#GET request
get '/sample09' do
  haml :sample09
end

#POST request
post '/sample09' do
  # Set variables
  set :file_id, params[:fileId]
  set :width, params[:width]
  set :height, params[:height]
  set :source, params[:source]
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :check, params[:check]
  set :url, params[:url]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.width.empty? or settings.height.empty?

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
    file = nil
    case settings.source
    when 'guid'
      file = GroupDocs::Storage::File.new({:guid => settings.file_id})
    when 'local'
      #Construct path
      filepath = "#{Dir.tmpdir}/#{params[:file][:filename]}"
      #Open file
      File.open(filepath, 'wb') { |f| f.write(params[:file][:tempfile].read) }
      #Make a request to API using client_id and private_key
      file = GroupDocs::Storage::File.upload!(filepath, {})
    when 'url'
      file = GroupDocs::Storage::File.upload_web!(settings.url)
    else
      raise 'Wrong GUID source.'
    end
     url = nil

    case settings.check
    when 'viewer'
      #Prepare to sign url
      iframe = "/document-viewer/embed/#{file.guid}?frameborder='0' width='#{settings.width}' height='#{settings.height}'"
    when 'annotation'
      #Prepare to sign url
      iframe = "/document-annotation2/embed/#{file.guid}?frameborder='0' width='#{settings.width}' height='#{settings.height}'"
    end
     #Sign url
    url = GroupDocs::Api::Request.new(:path => iframe).prepare_and_sign_url
    #Generate iframe URL
    case settings.base_path
      when 'https://stage-api-groupdocs.dynabic.com'
        iframe = "https://stage-api-groupdocs.dynabic.com#{url}"
      when 'https://dev-api-groupdocs.dynabic.com'
        iframe = "https://dev-apps.groupdocs.com#{url}"
      else
        iframe = "https://apps.groupdocs.com#{url}"
    end

  rescue Exception => e
    err = e.message
  end

  # Set variables for template
  haml :sample09, :locals => {:guid => file.guid, :width => settings.width, :height => settings.height, :v_url => iframe, :err => err}
end
