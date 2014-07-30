#GET request
get '/sample-41-how-to-set-callback-for-annotation-and-manage-user-rights' do
  haml :sample41
end

#POST request
post '/sample41/callback' do
  begin
    #Get callback request
    data = JSON.parse(request.body.read)
    serialized_data = JSON.parse(data['SerializedData'])

    raise 'Empty params!' if data.empty?

    file_guid = serialized_data['DocumentGuid']
    collaborator_guid = serialized_data['UserGuid']
    client_id = nil
    private_key = nil
     #Get private key and client_id from file user_info.txt
    if File.exist?("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = File.read("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = contents.split(' ')
      client_id = contents.first
      private_key = contents.last
    end
    status = nil
    if file_guid != '' and collaborator_guid != ''
      document = GroupDocs::Storage::File.new(:guid => file_guid).to_document
       #Get all collaborators for the document
      get_collaborator = document.collaborators!
      get_collaborator.each do |reviewer|
         #Set reviewer rights to view only
        reviewer.access_rights = %w(view)
      end
       #Make request to API to update reviewer rights
     status = document.set_reviewers! get_collaborator
    end

    #Create new file callback_info.txt and write the guid document
    out_file = File.new("#{File.dirname(__FILE__)}/../public/callback_info.txt", 'w')
    #White space is required
    out_file.write(status.nil? ? "Error" : "User rights was set to view only")
    out_file.close

  rescue Exception => e
    err = e.message
  end
end

#POST request
post '/sample41/check_guid' do
  pp 'test'
  begin
    result = nil
    i = 0
    for i in 1..10
      i +=1

      #Check is downloads folder exist
      if File.exist?("#{File.dirname(__FILE__)}/../public/callback_info.txt")
        result = File.read("#{File.dirname(__FILE__)}/../public/callback_info.txt")
        if result != ''
         break
        end
      end
      sleep(3)
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
post '/sample-41-how-to-set-callback-for-annotation-and-manage-user-rights' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :email, params[:email]
  set :source, params[:source]
  set :file_id, params[:fileId]
  set :url, params[:url]
  set :base_path, params[:basePath]
  set :callback, params[:callbackUrl]

  #Set download path
  downloads_path = "#{File.dirname(__FILE__)}/../public/downloads"

  #Remove all files from download directory or create folder if it not there
  if File.directory?(downloads_path)
    Dir.foreach(downloads_path) { |f| fn = File.join(downloads_path, f); File.delete(fn) if f != '.' && f != '..' }
    if File.exist?("#{File.dirname(__FILE__)}/../public/callback_info.txt")
      File.delete("#{File.dirname(__FILE__)}/../public/callback_info.txt")
    end
  else
    Dir::mkdir(downloads_path)
  end


  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.email.empty?

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
    if settings.callback
      out_file = File.new("#{File.dirname(__FILE__)}/../public/user_info.txt", 'w')
      #White space is required
      out_file.write("#{settings.client_id} ")
      out_file.write("#{settings.private_key}")
      out_file.close
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
    guid = file.guid
     #Create document object
    document = file.to_document
     #Set file sesion callback - will be trigered when user add, remove or edit commit for annotation
    session = document.set_session_callback! settings.callback


    #Get all users from accaunt
    users = GroupDocs::User.new.users!
    user_guid = nil
    # Number of collaborators
    number = Array.new
    if users
       #Pass of each email
      settings.email.each do |email|
         #Pass of each user and get user GUID if user with same email already exist
        users.map do |user|
           if user.primary_email == email
              #Get user GUID
             user_guid = user.guid
             break
           end
        end

         #Check is user with entered email was founded in GroupDocs account, if not user will be created
        if user_guid.nil?
          #Create new User object
          userNew = GroupDocs::User.new
          #Set email as entered email
          userNew.primary_email = settings.email
          #Set first name as entered first name
          userNew.firstname = settings.email
          #Set last name as entered last name
          userNew.lastname = settings.email
          #Set roles
          userNew.roles = [{:id => '3', :name => 'User'}]

          #Update account
          new_user = GroupDocs::User.update_account!(userNew)
          #Get user GUID
          user_guid = new_user.guid
        end
         #Get all collaborators for current document
        collaborators = document.collaborators!

        if collaborators
           #Pass of each collaborator
          collaborators.map do |collaborator|
             #Check is user with entered email already in collaborators
            if collaborator.primary_email == email
              number << collaborator.guid
            end
          end
        end
      end
       #Delete empty email
      if settings.email[1].empty? then settings.email.delete("") end
       #Add user as collaborators for the document
      document.set_collaborators! settings.email if number.size < 2
       #Add user GUID as "uid" parameter to the iframe URL
      iframe = "/document-annotation2/embed/#{file.guid}?uid=#{user_guid}"
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

      iframe = "<iframe src='#{iframe}' id='downloadframe' width='800' height='1000'></iframe>"
    end


  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample41, :locals => {:userId => settings.client_id, :fileId => settings.file_id, :privateKey => settings.private_key, :iframe => iframe, :callbackUrl => settings.callback, :err => err}
end
