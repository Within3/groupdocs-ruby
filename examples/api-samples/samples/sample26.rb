#GET request
get '/sample26' do
  haml :sample26
end

#POST request
post '/sample26' do
  set :email, params[:login]
  set :password, params[:password]
  set :base_path, params[:basePath]

  begin
    #Check required variables
    raise 'Please enter all required parameters' if settings.email.empty? or settings.password.empty?

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
      #Optionally specify API server and version
      groupdocs.api_server = base_path #Default is 'https://api.groupdocs.com'
    end
    #Make a request to API using email and password
    user = GroupDocs::User.login!(settings.email, settings.password)

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample26, :locals => {:user => user, :err => err}
end
