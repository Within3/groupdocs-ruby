# GET request
get '/sample22' do
  haml :sample22
end

# POST request
post '/sample22' do
  # Set variables
  set :client_id, params[:client_id]
  set :private_key, params[:private_key]
  set :fileId, params[:fileId]
  set :email, params[:email]
  set :first_name, params[:first_name]
  set :last_name, params[:last_name]
  set :base_path, params[:base_path]
  set :url, params[:url]
  set :source, params[:source]

  begin

    # Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.email.empty? or settings.first_name.empty? or settings.last_name.empty?

    if settings.base_path.empty? then settings.base_path = 'https://api.groupdocs.com' end

    # Configure your access to API server
    GroupDocs.configure do |groupdocs|
      groupdocs.client_id = settings.client_id
      groupdocs.private_key = settings.private_key
      # Optionally specify API server and version
      groupdocs.api_server = settings.base_path # default is 'https://api.groupdocs.com'
    end

    # get document by file GUID
    case settings.source
      when 'guid'
        # Create instance of File
        file = GroupDocs::Storage::File.new({:guid => settings.fileId}).to_document
      when 'local'
        # construct path
        file_path = "#{Dir.tmpdir}/#{params[:file][:filename]}"
        # open file
        File.open(file_path, 'wb') { |f| f.write(params[:file][:tempfile].read) }
        # make a request to API using client_id and private_key
        file = GroupDocs::Storage::File.upload!(file_path, {})
      when 'url'
        # Upload file from defined url
        file = GroupDocs::Storage::File.upload_web!(settings.url)
      else
        raise 'Wrong GUID source.'
    end

    # Create new user
    user = GroupDocs::User.new
    user.primary_email = settings.email
    user.nickname = settings.first_name
    user.first_name = settings.first_name
    user.last_name = settings.last_name

    # Update account
    new_user = GroupDocs::User.update_account!(user)


    # Set new collaboration
    file.set_collaborators!([settings.email], 2)

    # Get all collaborations
    collaborations = file.collaborators!()

    # Set document reviewers
    file.set_reviewers!(collaborations)

    #Get url from request
    case settings.base_path

      when 'https://stage-api-groupdocs.dynabic.com'
        url = "http://stage-apps-groupdocs.dynabic.com/document-annotation2/embed/#{file.file.guid}?uid = #{new_user.guid}&download=true"
      when 'https://dev-api-groupdocs.dynabic.com'
        url = "http://dev-apps-groupdocs.dynabic.com/document-annotation2/embed/#{file.file.guid}?uid = #{new_user.guid}&download=true"
      else
        url = "https://apps.groupdocs.com/document-viewer/document-annotation2/embed/#{file.file.guid}?uid = #{new_user.guid}&download=true"
    end

    # Add the signature to url the request

    iframe = GroupDocs::Api::Request.new(:path => url).prepare_and_sign_url

    iframe = "<iframe src='#{iframe}' frameborder='0' width='720' height='600'></iframe>"

  rescue Exception => e
    err = e.message
  end

  # set variables for template
  haml :sample22, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :fileId => settings.fileId, :email => settings.email, :first_name => settings.first_name, :last_name => settings.last_name, :iframe => iframe, :err => err}
end
