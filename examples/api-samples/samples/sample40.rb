#GET request
get '/sample-40-how-to-set-callback-for-signature-form-and-re-direct-when-it-was-signed' do
  haml :sample40
end

#POST request
post '/sample40/check_guid' do
  begin
    result = nil
    i = 0
    for i in 1..10
      i +=1
      #Check is downloads folder exist
      if File.exist?("#{File.dirname(__FILE__)}/../public/callback_info.txt")
        result = File.read("#{File.dirname(__FILE__)}/../public/callback_info.txt")
        if result != '' then break  end
      end
      sleep(5)
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
post '/sample40/callback' do

  source_id = ''
  client_id = ''
  private_key = ''

  #Get callback request
  data = JSON.parse(request.body.read)
  begin
    participant = nil
    raise 'Empty params!' if data.empty?

    #Get value of SourceId
    data.each do |key, value|
      if key == 'SourceId'
        source_id = value
      end
      if key == 'SerializedData'
       data = JSON.parse(value)
       data.each do |key, value|
         if key == 'ParticipantGuid'
           participant = value
         end
       end
      end
    end

    #Get private key and client_id from file user_info.txt
    if File.exist?("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = File.read("#{File.dirname(__FILE__)}/../public/user_info.txt")
      contents = contents.split(' ')
      client_id = contents[0]
      private_key = contents[1]
    end

    #Create new Form
    form = GroupDocs::Signature::Form.new({:id => source_id})
     #Create new Signature
    signature = GroupDocs::Signature.new()
    doc_info = signature.get_sign_form_participant!(form.id , participant, {:client_id => client_id, :private_key => private_key} )

    guid = doc_info[:documentGuid]

    out_file = File.new("#{File.dirname(__FILE__)}/../public/callback_info.txt", 'w')
     #White space is required
    out_file.write(guid)
    out_file.close

  rescue Exception => e
    err = e.message
  end
end



#POST request
post '/sample-40-how-to-set-callback-for-signature-form-and-re-direct-when-it-was-signed' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :form_guid, params[:formGuid]
  set :callback, params[:callbackUrl]
  set :base_path, params[:basePath]

  begin

    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.form_guid.empty?

    #Delete file callback_info.txt
    if File.exist?("#{File.dirname(__FILE__)}/../public/callback_info.txt")
      File.delete("#{File.dirname(__FILE__)}/../public/callback_info.txt")
    end

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
      out_file.close
    end

    guid = settings.form_guid

     #Create new Form with guid
    form = GroupDocs::Signature::Form.new()
    form.name = "Test Form"
     #Get id with new Form
    id = form.create!({:formId => guid})
     #Get Form
    form = GroupDocs::Signature::Form.get!(id)
     #Publish the Form
    form.publish!({:callbackUrl => settings.callback})

    #Prepare to sign url
    iframe = "//signature2/forms/signembed/#{guid}"
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

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample40, :locals => {:userId => settings.client_id,
                              :privateKey => settings.private_key,
                              :callback => settings.callback,
                              :iframe => iframe,
                              :err => err}
end
