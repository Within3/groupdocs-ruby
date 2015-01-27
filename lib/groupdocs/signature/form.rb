module GroupDocs
  class Signature::Form < Api::Entity

    include Api::Helpers::SignaturePublic
    include Signature::EntityMethods
    include Signature::DocumentMethods
    include Signature::FieldMethods
    extend  Signature::ResourceMethods

    # form doesn't have recipients
    undef_method :assign_field!

    STATUSES = {
      :draft       => -1,
      :in_progress =>  1,
      :completed   =>  2,
      :archived    =>  3,
    }

    #
    # Returns a list of all forms.
    #
    # @param [Hash] options Hash of options
    # @option options [Integer] :page Page to start with
    # @option options [Integer] :records How many items to list
    # @option options [Integer] :status_id Filter forms by status identifier
    # @option options [String] :document Filter forms by document GUID
    # @option options [String] :date Filter forms by date
    # @option options [String] :name Filter forms by name
    # @option options [String] :tag Filter forms by tag
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature::Form>]
    #
    def self.all!(options = {}, access = {})
      status_id = options.delete(:status_id)
      options[:statusId] = status_id if status_id

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/{{client_id}}/forms'
      end
      api.add_params(options)
      json = api.execute!

      json[:forms].map do |form|
        new(form)
      end
    end

    #
    # Returns form by its identifier.
    #
    # @param [String] id
    # @param [Hash] options
    # @option options [Boolean] :public Defaults to false
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Signature::Form]
    #
    def self.get!(id, options = {}, access = {})
      if options[:public]
        json = Api::Request.new do |request|
          request[:access] = access
          request[:method] = :GET
          request[:path] = "/signature/public/forms/#{id}"
        end.execute!

        new(json[:form])
      else
        super(id, access)
      end
    end

    # @attr [String] id
    attr_accessor :id
    # @attr [String] name
    attr_accessor :name
    # @attr [String] ownerGuid
    attr_accessor :ownerGuid
    # @attr [String] templateGuid
    attr_accessor :templateGuid
    # @attr [String] createdTimeStamp
    attr_accessor :createdTimeStamp
    # @attr [String] statusDateTime
    attr_accessor :statusDateTime
    # @attr [Integer] documentsCount
    attr_accessor :documentsCount
    # @attr [Integer] documentsPages
    attr_accessor :documentsPages
    # @attr [Integer] participantsCount
    attr_accessor :participantsCount
    # @attr [Array] fieldsInFinalFileName
    attr_accessor :fieldsInFinalFileName
    # @attr [Boolean] canParticipantDownloadForm
    attr_accessor :canParticipantDownloadForm
    # @attr [Symbol] status
    attr_accessor :status
    # @attr [String] waterMarkText
    attr_accessor :waterMarkText
    # @attr [String] waterMarkImage
    attr_accessor :waterMarkImage
    # @attr [Boolean] notifyOwnerOnSign
    attr_accessor :notifyOwnerOnSign

    #added in release 1.6.0
    # @attr [Boolean] canParticipantPrintForm
    attr_accessor :canParticipantPrintForm


    # Human-readable accessors
    alias_accessor :owner_guid,                    :ownerGuid
    alias_accessor :template_guid,                 :templateGuid
    alias_accessor :created_time_stamp,            :createdTimeStamp
    alias_accessor :status_date_time,              :statusDateTime
    alias_accessor :documents_count,               :documentsCount
    alias_accessor :documents_pages,               :documentsPages
    alias_accessor :participants_count,            :participantsCount
    alias_accessor :can_participant_download_form, :canParticipantDownloadForm
    alias_accessor :water_mark_text,               :waterMarkText
    alias_accessor :water_mark_image,              :waterMarkImage
    alias_accessor :notify_owner_on_sign,          :notifyOwnerOnSign

    #added in release 1.6.0
    alias_accessor :can_participant_print_form,    :canParticipantPrintForm

    #
    # Converts status to human-readable format.
    # @return [Symbol]
    #
    def status
      STATUSES.invert[@status]
    end

    #
    # Converts array of field names to machine-readable format.
    # @param [Array<String>] fields
    #
    def fields_in_final_file_name=(fields)
      if fields.is_a?(Array)
        fields = fields.join(',')
      end

      @fieldsInFinalFileName = fields
    end

    #
    # Converts field names to human-readable format.
    # @return [Array<String>]
    #
    def fields_in_final_file_name
      @fieldsInFinalFileName.split(',') if @fieldsInFinalFileName
    end

    #
    # Creates form.
    #
    # @example
    #   form = GroupDocs::Signature::Form.new
    #   form.name = "Form"
    #   form.create!
    #
    # @param [Hash] options Hash of options
    # @option options [String] :template_id Template GUID to create form from
    # @option options [Integer] :assembly_id Questionnaire identifier to create form from
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if template is not GroupDocs::Signature::Template
    #
    def create!(options = {}, access = {})
      #template_id = options.delete(:template_id)
      #assembly_id = options.delete(:assembly_id)
      #options[:templateId] = template_id if template_id
      #options[:assemblyId] = assembly_id if assembly_id

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = '/signature/{{client_id}}/form'
        request[:request_body] = to_hash

      end

      api.add_params(options.merge(:name => name))
      json = api.execute!

      self.id = json[:form][:id]
    end

    #
    # Returns documents array.
    #
    # @param [Hash] options
    # @option options [Boolean] :public Defaults to false
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document>]
    #
    def documents!(options = {}, access = {})
      client_id = client_id(options[:public])

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/#{client_id}/forms/#{id}/documents"
      end.execute!

      json[:documents].map do |document|
        id = document[:documentId] || document[:id]
        file = Storage::File.new(:guid => id, :name => document[:name])
        Document.new(document.merge(:file => file))
      end
    end

    #
    # Publishes form.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @param callbackUrl [Hash] Webhook Callback Url
	# @option callbackUrl [String] :callbackUrl  
    #
    def publish!(callbackUrl = {}, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/forms/#{id}/publish"
        request[:request_body] = callbackUrl
      end.execute!
    end

    #
    # Completes form.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def complete!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/forms/#{id}/complete"
      end.execute!
    end

    #
    # Archives completed form.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def archive!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/forms/#{id}/archive"
      end.execute!
    end

    #
    # Changed in release 2.0.0
    #
    # Returns an array of fields for document per participant.
    #    
    # @param  [Hash] options
    # @option options [String] :field Field GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def get_fields!(options = {}, access = {})

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/forms/#{id}/fields"
      end
      api.add_params(options)
      json = api.execute!

      json[:fields].map do |field|
        Signature::Field.new(field)
      end
    end


    #
    # Adds field for document.
    #
    # @example
    #   form = GroupDocs::Signature::Form.get!("g94h5g84hj9g4gf23i40j")
    #   field = GroupDocs::Signature::Field.get!.detect { |f| f.type == :signature }
    #   field.location = { location_x: 0.1, location_y: 0.1, page: 1 }
    #   document = form.documents!.first
    #   form.add_field! field, document
    #
    # @param [GroupDocs::Signature::Field] field
    # @param [GroupDocs::Document] document
    # @param [Hash] options
    # @option options [Boolean] :force_new_field Set to true to force new field create
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if field is not GroupDocs::Signature::Field
    # @raise [ArgumentError] if document is not GroupDocs::Document
    # @raise [ArgumentError] if field does not specify location
    #
    def add_field!(field, document, opts = {}, access = {})
      field.is_a?(GroupDocs::Signature::Field) or raise ArgumentError,
        "Field should be GroupDocs::Signature::Field object, received: #{field.inspect}"
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
        "Document should be GroupDocs::Document object, received: #{document.inspect}"
      field.location or raise ArgumentError,
        "You have to specify field location, received: #{field.location.inspect}"

      opts[:force_new_field] = true if opts[:force_new_field].nil?
      payload = field.to_hash # field itself
      payload.merge!(field.location.to_hash) # location should added in plain view (i.e. not "location": {...})
      payload.merge!(:forceNewField => opts[:force_new_field]) # create new field flag

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/signature/{{client_id}}/forms/#{id}/documents/#{document.file.guid}/field/#{field.id}"
        request[:request_body] = payload
      end.execute!
    end

    #
    # Modifies field location.
    #
    # @example Modify field location in template
    #   form = GroupDocs::Signature::Form.get!("g94h5g84hj9g4gf23i40j")
    #   document = form.documents!.first
    #   field = form.fields!(document).first
    #   location = field.locations.first
    #   location.x = 0.123
    #   location.y = 0.123
    #   location.page = 2
    #   form.modify_field_location! location, field, document
    #
    # @param [GroupDocs::Signature::Field::Location] location
    # @param [GroupDocs::Signature::Field] field
    # @param [GroupDocs::Document] document
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if location is not GroupDocs::Signature::Field::Location
    # @raise [ArgumentError] if field is not GroupDocs::Signature::Field
    # @raise [ArgumentError] if document is not GroupDocs::Document
    #
    def modify_field_location!(location, field, document, access = {})
      location.is_a?(GroupDocs::Signature::Field::Location) or raise ArgumentError,
        "Location should be GroupDocs::Signature::Field::Location object, received: #{location.inspect}"
      field.is_a?(GroupDocs::Signature::Field) or raise ArgumentError,
        "Field should be GroupDocs::Signature::Field object, received: #{field.inspect}"
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
        "Document should be GroupDocs::Document object, received: #{document.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/forms/#{id}/documents/#{document.file.guid}/fields/#{field.id}/locations/#{location.id}"
        request[:request_body] = location.to_hash
      end.execute!
    end

    #
    # Updates form adding fields from template.
    #
    # @param [GroupDocs::Signature::Template] template
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if template is not GroupDocs::Signature::Template
    #
    def update_from_template!(template, access = {})
      template.is_a?(GroupDocs::Signature::Template) or raise ArgumentError,
        "Template should be GroupDocs::Signature::Template object, received: #{template.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/signature/{{client_id}}/forms/#{id}/templates/#{template.id}"
      end.execute!
    end

    #
    # Modify signature form document
    #
    # @example
    #   form = GroupDocs::Signature::Form.get!("g94h5g84hj9g4gf23i40j")
    #   document = form.documents!.first
    #   field = form.fields!(document).first
    #   field.name = "Field"
    #   envelope.modify_field! field, document
    #
    #
    # @param [GroupDocs::Document] document
    # @param [Hash] options
    # @option options [Integer] Order
    # @option options [String] newDocumentGuid
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if document is not GroupDocs::Document
    #
    def modify_form_document!(document, options = {}, access = {})
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
                                                   "Document should be GroupDocs::Document object, received: #{document.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/forms/#{id}/document/#{document.file.guid}/"
        request[:request_body] = options
      end.execute!
    end

    #
    # Changed in release 1.5.8
    #
    # Downloads signed documents to given path.
    # If there is only one file in envelope, it's saved as PDF.
    # If there are two or more files in envelope, it's saved as ZIP.
    #
    # @param [String] path Directory to download file to
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String] path to file
    #
    def signed_documents!(path, access = {})
      response = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DOWNLOAD
        request[:path] = "/signature/{{client_id}}/forms/#{id}/documents/get"
      end.execute!

      filepath = "#{path}/#{name}.zip"


      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

    #
    # Changed in release 1.5.8
	#
	# Public fill signature form.
    #
    # @param [String] form Form GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def public_fill!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/forms/#{id}/fill"
      end.execute!
    end

    #
    # Changed in release 1.5.8
    #
    # Public fill form field.
    #
    # @example Fill single line field
    #   form = GroupDocs::Signature::Form.get!("g94h5g84hj9g4gf23i40j")
    #   document = form.documents!.first
    #   field = form.fields!(document).first
    #   fill_form = form.public_fill!
    #   participant = fill_form[:participant][:id]
    #   envelope.fill_field! "my_data", field, document, participant
    #
    # @example Fill signature field
    #   form = GroupDocs::Signature::Form.get!("g94h5g84hj9g4gf23i40j")
    #   document = form.documents!.first
    #   field = form.fields!(document).first
    #   fill_form = form.public_fill!
    #   participant = fill_form[:participant][:id]
    #   signature = GroupDocs::Signature.get!.first
    #   form.fill_field! signature, field, document, participant
    #
    # @example Fill checkbox field
    #   form = GroupDocs::Signature::Form.get!("g94h5g84hj9g4gf23i40j")
    #   document = form.documents!.first
    #   field = form.fields!(document).first
    #   fill_form = form.public_fill!
    #   participant = fill_form[:participant][:id]
    #   form.fill_field! false, field, document, participant
    #
    #
    # @param [GroupDocs::Document] document Document GUID
    # @param [String] participant Participant ID
    # @param [GroupDocs::Signature::Field] field Field GUID
    # @param [String] authentication Authentication signature
    # @param [File Stream] value Data to be placed in field
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def public_fill_field!(value, field, document, participant, authentication,  access = {})
      field.is_a?(GroupDocs::Signature::Field) or raise ArgumentError,
                                                        "Field should be GroupDocs::Signature::Field object, received: #{field.inspect}"
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
                                                   "Document should be GroupDocs::Document object, received: #{document.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/public/forms/#{id}/documents/#{document.guid}/participant/#{participant}/field/#{field.id}"
        request[:request_body] = value
        request[:plain] = true
      end
      api.add_params(:participantAuthSignature => authentication)
      json = api.execute!
      Signature::Field.new(json[:field])
    end

    #
    # Changed in release 1.7.0
    #
    # Public sign form.
    #
    # @param [Hash] settings
    # @option settings [String] :authData (required)
    # @option settings [String] :comment (required)
    # @param [String] filepath Path to file to be uploaded
    # @param [String] participant Participant GUID
    # @param [String] authentication Authentication signature
    # @param [String] participant_name Participant Name
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def sign!( filepath, participant, authentication, participant_name, settings = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/public/forms/#{id}/participant/#{participant}/sign"
        request[:request_body] = Object::File.new(filepath, 'rb')
        request[:request_body] = settings

      end
      api.add_params(:participantAuthSignature => authentication, :name => participant_name)
      api.execute!
    end

    #
    #  Changed in release 1.5.8
    #
    #
    # Get form fields for document in form per participant
    #
    # @param [Hash] options
    # @option [String] :document Document GUID
    # @option [String] :participant Participant GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def public_fields!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/forms/#{id}/fields"
      end
      api.add_params(options)
      json = api.execute!

      json[:fields].map do |field|
        Signature::Field.new(field)
      end
    end

    #
    #  Changed in release 1.5.8
    #
    #
    # Get signature form participant.
    #
    # @param [String] participant Participant GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def participant!(participant, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/forms/#{form}/participants/#{participant}"
      end.execute!

      json[:participant]
    end

    #
    # Changed in release 1.5.8
    #
    #
    # Get signed form documents.
    #
    # @param [String] participant Participant GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def public_signed_documents!(path, participant, access = {})
      response = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DOWNLOAD
        request[:path] = "/signature/public/forms/#{id}/participant/#{participant}/documents/get"
      end.execute!


      filepath = "#{path}/#{name}."
      if documents!.size == 1
        filepath << 'pdf'
      else
        filepath << 'zip'
      end

      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

    #
    # Added in release 1.7.0
    #
    # Update Form Participant.
    #
    # @param [String] form Form GUID
    # @param [String] participant Participant GUID
    # @param [String] authentication Authentication signature
    # @param [String] participant_name Participant Name
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def update_partipicant!(participant, email, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/public/forms/#{id}/participant/#{participant}"
      end
      api.add_params(:email => email)
      api.execute!
    end

    #
    # Added in release 1.7.0
    #
    # Validate Particpiant Identity.
    #
    # @param [String] participant Participant GUID
    # @param [String] code Code to be validated
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def validate_partipicant!(participant, code, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/forms/#{id}/participant/#{participant}/validationCode/#{code}"
      end.execute!
    end

    #
    # Added in release 1.7.0
    #
    # Get form fields for document in form per participant.
    #
    # @param [GroupDocs::Document] document
    # @param  [Hash] options
    # @option options [String] :field Field GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if document is not GroupDocs::Document
    #
    def document_fields!(document, options = {}, access = {})
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
                                                   "Document should be GroupDocs::Document object, received: #{document.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/forms/#{id}/documents/#{document.file.guid}/fields"
      end
      api.add_params(options)
      json = api.execute!

      json[:fields].map do |field|
        Signature::Field.new(field)
      end
    end

    #
    # Added in release 1.7.0
    #
    # Get form audit logs
    #
    # @param  [Hash] options
    # @option options [String] :field Field GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if document is not GroupDocs::Document
    #
    def get_logs!(access = {})

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/forms/#{id}/logs"
      end.execute!
    end

    #
    # Added in release 1.8.0
    #
    # Get form participants
    #
    # @param  [Hash] options
    # @option options [String] :field Field GUID
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if document is not GroupDocs::Document
    #
    def get_participants!(access = {})

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/{{client_id}}/forms/#{id}/participants"
      end.execute!
    end

  end # Signature::Form
end # GroupDocs
