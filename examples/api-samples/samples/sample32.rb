#GET request
get '/sample-32-how-to-create-signature-form-publish-it-and-configure-notification-when-it-was-signed' do
  haml :sample32
end

#POST request
post '/sample32/callback' do

  source_id = ''
  client_id = ''
  private_key = ''
  subscriber_email = ''

  #Get callback request
  data = JSON.parse(request.body.read)
  begin
    raise 'Empty params!' if data.empty?

    #Get value of SourceId
    data.each do |key, value|
      if key == 'SourceId'
        source_id = value
      end
    end

    #Get private key and client_id from file user_info.txt
    if File.exist?("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = File.read("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = contents.split(' ')
      client_id = contents[0]
      private_key = contents[1]
      subscriber_email = contents[2]
    end

    #Create new Form
    form = GroupDocs::Signature::Form.new({:id => source_id})

    #Get document by Form id
    document = form.documents!({:client_id => client_id, :private_key => private_key})

    #An adress recipient
    to = subscriber_email

    #The Body message
    body = "
          <html>
            <head>
              <title>Sign form notification</title>
            </head>
            <body>
              <p>Document #{document.name} is signed</p>
            </body>
          </html>"


    #A method send the mail
    def send_mail(to, body)
      #Implement your send mail function with your SMTP server
       return true
    end

    send_mail(to, body)  #Send notification mail

  rescue Exception => e
    err = e.message
  end
end

#POST request
post '/sample-32-how-to-create-signature-form-publish-it-and-configure-notification-when-it-was-signed' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :template_guid, params[:templateGuid]
  set :form_guid, params[:formGuid]
  set :email, params[:email]
  set :callback, params[:callbackUrl]
  set :source, params[:source]
  set :base_path, params[:basePath]

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

    #Write client and private key to the file for callback job
    if settings.callback
      out_file = File.new("#{File.dirname(__FILE__)}/../public/user_info.txt", 'w')
      #White space is required
      out_file.write("#{settings.client_id} ")
      out_file.write("#{settings.private_key} ")
      out_file.write("#{settings.email}")
      out_file.close
    end

    guid = nil
    url = nil

    case settings.source
    when 'form'
      id = settings.form_guid
      #Create new Form with guid
      form = GroupDocs::Signature::Form.new
      form.name = 'test'
      form.notifyOwnerOnSign = true

      #Create new Form with template
      id = form.create!({:formId => guid})
      form = GroupDocs::Signature::Form.get!(id)

      #Publish the Form
      form.publish!({:callbackUrl => settings.callback})
      guid = settings.form_guid

    when 'template'

      form = GroupDocs::Signature::Form.new
      form.name = 'test'
      form.notifyOwnerOnSign = true

     #Create new Form with template
     guid = form.create!({ :templateId => settings.template_guid})

      #Publish the Form
      form.publish!({:callbackUrl => settings.callback})

    end

    #Prepare to sign url
    iframe = "/signature2/forms/signembed/#{guid}"
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

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample32, :locals => {:userId => settings.client_id,
                              :privateKey => settings.private_key,
                              :callback => settings.callback,
                              :email => settings.email,
                              :iframe => iframe,
                              :err => err}
end
