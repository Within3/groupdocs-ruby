#GET request
get '/sample-35-how-to-create-assembly-from-document-and-merge-fields' do
  haml :sample35
end


#POST request
post '/sample-35-how-to-create-assembly-from-document-and-merge-fields' do
  #Set variables
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :source, params[:source]
  set :file_id, params[:fileId]
  set :url, params[:url]
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

    #Configure your access to API server.
    GroupDocs.configure do |groupdocs|
      groupdocs.client_id = settings.client_id
      groupdocs.private_key = settings.private_key
      #Optionally specify API server and version
      groupdocs.api_server = base_path # default is 'https://api.groupdocs.com'

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

    #Raise exception if something went wrong
    raise 'No such file' unless file.is_a?(GroupDocs::Storage::File)


    #Make GroupDocs::Storage::Document instance
    document = file.to_document
    #Get array of document's fields
    fields = document.fields!

    #Create the fields for form
    html = ''
    fields.map do |e|

      case e.type
      when 'Text'
        signature = "<br/><label for='#{e.name}'>#{e.name} #{e.mandatory == false ? '<span class="optional">(Optional)</span>' : '<span class="optional">(Required)</span>'}</label><br/><input type='text' name='#{e.name}'></input><br/><br/>"
        html << signature
      when 'RadioButton'
        i = 0
        html.scan(e.name).empty? ? '' : i += 1
        radio = "<br/><label for='#{e.name}'>#{e.name} #{e.mandatory == false ? '<span class="optional">(Optional)</span>' : '<span class="optional">(Required)</span>'}</label><br/><input type='radio' name='#{e.name}' value='#{i}' ></input><br/><br/>"
        html << radio
      when 'Checkbox'
        checkbox = "<br/><label for='#{e.name}'>#{e.name} #{e.mandatory == false ? '<span class="optional">(Optional)</span>' : '<span class="optional">(Required)</span>'}</label><br/><input type='checkbox' name='#{e.name}' ></input><br/><br/>"
        html << checkbox
      when 'Combobox'
        combobox = "<br/><label for='#{e.name}'>#{e.name} #{e.mandatory == false ? '<span class="optional">(Optional)</span>' : '<span class="optional">(Required)</span>'}</label><br/><select name='#{e.name}'>"
        e.acceptableValues.each { |e| combobox << "<option name='#{e}'>#{e}</option>"}
        combobox << "</select><br/><br/>"
        html << combobox
      when 'Listbox'
        listbox = "<br/><label for='#{e.name}'>#{e.name} #{e.mandatory == false ? '<span class="optional">(Optional)</span>' : '<span class="optional">(Required)</span>'}</label><br/><select multiple name='#{e.name}[]'>"
        e.acceptableValues.each { |e| listbox << "<option name='#{e}'>#{e}</option>"}
        listbox << "</select><br/><br/>"
        html << listbox
      end

    end

  rescue Exception => e
    err = e.message
  end

  #Set variables for template
  haml :sample35, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :fileId => document.file.guid, :base_path => settings.base_path,  :html => html, :err => err}
end

#GET request
get '/sample-35-how-to-create-assembly-from-document-and-merge-fields/check' do
  haml :sample35
end

#POST request
post '/sample-35-how-to-create-assembly-from-document-and-merge-fields/check' do
  set :client_id, params[:clientId]
  set :private_key, params[:privateKey]
  set :base_path, params[:basePath]
  set :file_id, params[:fileId]

  begin

    #Prepare base path
    if settings.base_path.empty?
      base_path = 'https://api.groupdocs.com'
    elsif settings.base_path.match('/v2.0')
      base_path = settings.base_path.split('/v2.0')[0]
    else
      base_path = settings.base_path
    end

    #Get document by file GUID
    GroupDocs.configure do |groupdocs|
      groupdocs.client_id = settings.client_id
      groupdocs.private_key = settings.private_key
      #Optionally specify API server and version
      groupdocs.api_server = base_path # default is 'https://api.groupdocs.com'
    end


    #TODO:
    #Merge template PDF FIle with the data provided via dynamically created HTML form.

    #Create instance of File
    document = GroupDocs::Storage::File.new({:guid => settings.file_id}).to_document

    #Create datasource with fields
    datasource = GroupDocs::DataSource.new

    #Get array of document's fields
    fields = document.fields!()

    #Get unique fields
    fields = fields.uniq{ |f| f.name }

    datasource.fields = []

    #Create Field instance and fill the fields
    fields.each do |field|
      if field.type == 'Text'
        datasource.fields << GroupDocs::DataSource::Field.new(name: field.name, type: :text, values: [params[field.name.to_sym]])
      end

      if field.type == "RadioButton" && params[field.name.to_sym]
        datasource.fields << GroupDocs::DataSource::Field.new(name: field.name, type: 'integer', values: [params[field.name.to_sym]])

      end

      if field.type == "Checkbox" && params[field.name.to_sym] == 'on'
        datasource.fields << GroupDocs::DataSource::Field.new(name: field.name, type: 'boolean', values: [true])
      end

      if field.type == "Combobox" && params[field.name.to_sym]
          i = 0
          value = nil
          field.acceptableValues.each do |e|
            e == params[field.name] ? value = i : ''
            i += 1
          end

        datasource.fields << GroupDocs::DataSource::Field.new(name: field.name, type: 'integer', values: [value])
      end

      if field.type == "Listbox" && params[field.name.to_sym]
          i = 0
          value = nil
          field.acceptableValues.each do |e|
            e == params[field.name] ? value = i : ''
            i += 1
          end
        datasource.fields << GroupDocs::DataSource::Field.new(name: field.name, type: 'integer', values: [value])

      end

    end

    #Adds datasource.
    datasource.add!()

    #Creates new job to merge datasource into document.
    job = document.datasource!(datasource, {:new_type => 'pdf'})

    i = 0
    #Checks status of Job.
    while i<5 do
      sleep(5)
      job_status = GroupDocs::Job.get!(job.id)
      break if job_status.status == :archived
      i += 1
    end

    #Returns an hash of input and output documents associated to job.
    document = job.documents!()

    #Set converted document GUID
    guid = document[:inputs][0].outputs[0].guid

    #Prepare to sign url
    iframe = "/document-viewer/embed/#{guid}"
    # Construct result string
    url = GroupDocs::Api::Request.new(:path => iframe).prepare_and_sign_url
    #Generate iframe URL
    case base_path
      when 'https://stage-api-groupdocs.dynabic.com'
        iframe = "https://stage-apps-groupdocs.dynabic.com/#{url}"
      when 'https://dev-api-groupdocs.dynabic.com'
        iframe = "https://dev-apps-groupdocs.dynabic.com#{url}"
      else
        iframe = "https://apps.groupdocs.com#{url}"
    end

    #Make iframe
    iframe = "<iframe id='downloadframe' src='#{iframe}' width='800' height='1000'></iframe>"

  rescue Exception => e
    err = e.message
  end

  haml :sample35, :locals => {:userId => settings.client_id, :privateKey => settings.private_key, :iframe => iframe, :err => err}
end