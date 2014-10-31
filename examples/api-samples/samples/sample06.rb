#GET request
get '/sample-6-how-to-add-a-signature-to-a-document-in-groupdocs-signature' do
  haml :sample06
end

#POST request
post '/sample-6-how-to-add-a-signature-to-a-document-in-groupdocs-signature' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :base_path, params[:basePath]
  require 'net/http'

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


    #Construct file path and open file
    file_one_path = "#{File.dirname(__FILE__)}/#{params[:fiDocument][:filename]}"
    File.open(file_one_path, 'wb') { |f| f.write(params[:fiDocument][:tempfile].read) }


    #Create new file
    file_one = GroupDocs::Storage::File.new(name: params[:fiDocument][:filename], local_path: file_one_path)
    document_one = file_one.to_document

    #Construct signature path and open file
    signature_one_path = "#{Dir.tmpdir}/#{params[:fiSignature][:filename]}"
    File.open(signature_one_path, 'wb') { |f| f.write(params[:fiSignature][:tempfile].read) }

    #Add signature to file using API
    signature_one = GroupDocs::Signature.new(name: params[:fiSignature][:filename], image_path: signature_one_path)
    signature_one.position = {top: 0.83319, left: 0.72171, width: 100, height: 40}
    signature_one.email = "test@email.com"

    #Make a request to API using client_id and private_key
    signed_documents = GroupDocs::Document.sign_documents!([document_one], [signature_one], {})
    sleep(5)

    #Get the document guid
    document = GroupDocs::Signature.sign_document_status!(signed_documents)
                                              to
    #Prepare to sign url
    iframe = "/document-viewer/embed/#{document.guid}"
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

    #Generate result
    if signed_documents
      #Make iframe
      iframe = "<iframe id='downloadframe' src='#{iframe}' width='800' height='1000'></iframe>"
    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample06, :locals => {:clientId => settings.client_id, :privateKey => settings.private_key, :iframe => iframe, :err => err}
end