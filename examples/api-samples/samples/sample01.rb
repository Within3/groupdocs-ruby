#GET request
get '/sample-1-how-to-login-to-groupdocs-using-the-api' do
  haml :sample01
end

#POST request
post '/sample-1-how-to-login-to-groupdocs-using-the-api' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :base_path, params[:basePath]

  begin

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

    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty?

    #Make a request to API using client_id and private_key
    user = GroupDocs::User.get!()

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample01, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :user => user, :err => err}
end
