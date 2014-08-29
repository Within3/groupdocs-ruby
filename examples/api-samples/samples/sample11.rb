#GET request
get '/sample-11-how-programmatically-create-and-post-an-annotation-into-document' do
  haml :sample11
end

#POST request
post '/sample-11-how-programmatically-create-and-post-an-annotation-into-document' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :file_id, params[:fileId]
  set :annotation_type, params[:annotationType]
  set :annotation_id, params[:annotationId]
  set :base_path, params[:basePath]

  begin

    #Check required variables
    raise 'Please enter all required parameters' if settings.client_id.empty? or settings.private_key.empty? or settings.file_id.empty? or settings.annotation_type.empty?

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

    if settings.annotation_id != ''

      file = GroupDocs::Storage::File.new({:guid => settings.file_id}).to_document
      annotation = file.annotations!()

      #Remove annotation from document
      remove = annotation.last.remove!()
      message = "You delete the annotation id = #{remove[:guid]} "
    else
      #Annotation types
      types = {:text => "0", :area => "1", :point => "2"}


      #Required parameters
      all_params = all_params = ['annotationType', 'boxX', 'boxY', 'text']

      #Added required parameters depends on  annotation type ['text' or 'area']
      if settings.annotation_type == 'text'
        all_params = all_params | ['boxWidth', 'boxHeight', 'annotationPositionX', 'annotationPositionY', 'rangePosition', 'rangeLength']
      elsif settings.annotation_type == 'area'
        all_params = all_params | ['boxWidth', 'boxHeight']
      end

      #Checking required parameters
      all_params.each do |param|
        raise 'Please enter all required parameters' if params[param].empty?
      end

      #Create document object
      document = GroupDocs::Storage::File.new(guid: settings.file_id).to_document

      unless document.instance_of? String

        #Start create new annotation
        annotation = GroupDocs::Document::Annotation.new(document: document)

        info = nil
        #Construct requestBody depends on annotation type
        #Text annotation
        if settings.annotation_type == 'text'
          annotation.box = GroupDocs::Document::Rectangle.new ({x: params['boxX'], y: params['boxY'], width: params['boxWidth'], height: params['boxHeight']})
          annotation.annotationPosition = {x: params['annotationPositionX'], y: params['annotationPositionY']}
          range = {position: params['rangePosition'], length: params['rangeLength']}
          info = {:box => annotation_box, :annotationPosition => annotation_annotationPosition, :range => range, :type => types[settings.annotation_type.to_sym], :replies => [{:text => params['text']}]}
          #Area annotation
        elsif settings.annotation_type == 'area'
          annotation_box = {x: params['boxX'], y: params['boxY'], width: params['boxWidth'], height: params['boxHeight']}
          annotation_annotationPosition = {x: 0, y: 0}
          info = {:box => annotation_box, :annotationPosition => annotation_annotationPosition, :type => types[settings.annotation_type.to_sym], :replies => [{:text => params['text']}]}
          #Point annotation
        elsif settings.annotation_type == 'point'
          annotation_box = {x: params['boxX'], y: params['boxY'], width: 0, height: 0}
          annotation_annotationPosition = {x: 0, y: 0}

          info = {:box => annotation_box, :annotationPosition => annotation_annotationPosition, :type => types[settings.annotation_type.to_sym], :replies => [{:text => params['text']}] }
        end

        #Call create method
        annotation.create!(info)
        id = annotation.document.file.id
        #Get document guid
        guid = annotation.document.file.guid

        #Prepare to sign url
        iframe = "/document-annotation2/embed/#{guid}"
        #Construct result string
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

      end
    end

  rescue Exception => e
    err = e.message
  end

  # set variables for template
  haml :sample11, :locals => {:clientId => settings.client_id,
                              :privateKey => settings.private_key,
                              :fileId => settings.file_id,
                              :annotationType => settings.annotation_type,
                              :annotationId => id,
                              :annotationText => params['text'],
                              :err => err,
                              :iframe => iframe,
                              :message => message}
end