#GET request
get '/sample45' do
  haml :sample45
end

#POST request
post '/sample45' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :folder_name, params[:folderName]
  set :file_name, params[:fileName]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.file_name.empty?

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


    #Make a request to API using client_id and private_key
   if settings.folder_name.empty? then  files_list = GroupDocs::Storage::Folder.list!('/', {}) else files_list = GroupDocs::Storage::Folder.list!(settings.folder_name + '/', {})  end

    #Construct list of files
    result = ''
    files_list.each do |element|
      if element.name == settings.file_name
        #Construct html result
        file = element.to_document.metadata!
        result += "<p>Total document's info: </p>"
        result += "<table class='border'>"
        result += "<tr><td><font color='green'>Parameter</font></td><td><font color='green'>Info</font></td></tr>"
        result += "<tr><td>page_count</td><td>#{file.page_count}</td></tr>"
        result += "<tr><td>views_count</td><td>#{file.views_count}</td></tr>"
        result += "<tr><td>name</td><td>#{file.last_view.document.file.name}</td></tr>"
        result += "<tr><td>version</td><td>#{file.last_view.document.file.version}</td></tr>"
        result += "<tr><td>size</td><td>#{file.last_view.document.file.size}</td></tr>"
        result += "<tr><td>type</td><td>#{file.last_view.document.file.type}</td></tr>"
        result += "<tr><td>file_type_str</td><td>#{file.last_view.document.file.file_type}</td></tr>"
        result += "<tr><td>access</td><td>#{file.last_view.document.file.access}</td></tr>"
        result += "<tr><td>url</td><td>#{file.last_view.document.file.url}</td></tr>"
        result += "<tr><td>id</td><td>#{file.last_view.document.file.id}</td></tr>"
        result += "<tr><td>guid</td><td>#{file.last_view.document.file.guid}</td></tr>"
        result += "<tr><td>short_url</td><td>#{file.last_view.short_url}</td></tr>"
        result += "<tr><td>viewed_on</td><td>#{file.last_view.viewed_on}</td></tr>"
        result += "<tr bgcolor='#808080'><td></td><td></td></tr>"
        result += '</table>'
      end
    end

    if result.empty? then result = 'File is not in this folder' end
  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample45, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :result => result,   :err => err}
end