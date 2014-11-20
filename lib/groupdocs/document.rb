module GroupDocs
  class Document < Api::Entity

    require 'groupdocs/document/annotation'
    require 'groupdocs/document/change'
    require 'groupdocs/document/field'
    require 'groupdocs/document/metadata'
    require 'groupdocs/document/rectangle'
    require 'groupdocs/document/view'
    require 'groupdocs/document/editor'
    require 'groupdocs/document/style'

    ACCESS_MODES = {
        :private    => 0,
        :restricted => 1,
        :public     => 2,
        :inherited  => 254,
        :denied     => 255,
    }

    include Api::Helpers::AccessMode
    include Api::Helpers::AccessRights
    include Api::Helpers::Status
    extend Api::Helpers::MIME

    #
    # Returns an array of views for all documents.
    #
    # @param [Hash] options
    # @option options [Integer] :page_index Page to start with
    # @option options [Integer] :page_size Total number of entries
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document::View>]
    #
    def self.views!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/doc/{{client_id}}/views'
      end
      api.add_params(options)
      json = api.execute!

      json[:views].map do |view|
        Document::View.new(view)
      end
    end

    #
    # Returns an array of all templates (documents in "Templates" directory).
    #
    # @param [Hash] options Options
    # @option options [String] :orderBy Order by column
    # @option options [Boolean] :isAscending Order by ascending or descending
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document>]
    #
    def self.templates!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/merge/{{client_id}}/templates'
      end
      api.add_params(options)
      json = api.execute!
      json[:templates].map do |template|
        template.merge!(:file => Storage::File.new(template))
        Document.new(template)
      end
    end

    #
    # Signs given documents with signatures.
    #
    # @example
    #   # prepare documents
    #   file_one = GroupDocs::Storage::File.new(name: 'document_one.doc', local_path: '~/Documents/document_one.doc')
    #   file_two = GroupDocs::Storage::File.new(name: 'document_one.pdf', local_path: '~/Documents/document_one.pdf')
    #   document_one = file_one.to_document
    #   document_two = file_two.to_document
    #   # prepare signatures
    #   signature_one = GroupDocs::Signature.new(name: 'John Smith', image_path: '~/Documents/signature_one.png')
    #   signature_two = GroupDocs::Signature.new(name: 'Sara Smith', image_path: '~/Documents/signature_two.png')
    #   signature_one.position = { top: 0.1, left: 0.07, width: 50, height: 50 }
    #   signature_one.email = "test1@mail.com"
    #   signature_two.position = { top: 0.2, left: 0.2, width: 100, height: 100 }
    #   signature_one.email = "test1@mail.com"
    #   # sign documents and download results
    #   signed_documents = GroupDocs::Document.sign_documents!([document_one, document_two], [signature_one, signature_two])
    #   signed_documents.each do |document|
    #     document.file.download! '~/Documents'
    #   end
    #
    # @param [Array<GroupDocs::Document>] documents Each document file should have "#name" and "#local_path"
    # @param [Array<GroupDocs::Signature>] signatures Each signature should have "#name", "#image_path" and "#position"
    #
    def self.sign_documents!(documents, signatures, options = {}, access = {})
      documents.each do |document|
        document.is_a?(Document) or raise ArgumentError, "Each document should be GroupDocs::Document object, received: #{document.inspect}"
        document.file.name       or raise ArgumentError, "Each document file should have name, received: #{document.file.name.inspect}"
        document.file.local_path or raise ArgumentError, "Each document file should have local_path, received: #{document.file.local_path.inspect}"
      end
      signatures.each do |signature|
        signature.is_a?(Signature) or raise ArgumentError, "Each signature should be GroupDocs::Signature object, received: #{signature.inspect}"
        signature.name             or raise ArgumentError, "Each signature should have name, received: #{signature.name.inspect}"
        signature.image_path       or raise ArgumentError, "Each signature should have image_path, received: #{signature.image_path.inspect}"
        signature.position         or raise ArgumentError, "Each signature should have position, received: #{signature.position.inspect}"
      end

      documents_to_sign = []
      documents.map(&:file).each do |file|
        document = { :name => file.name }
        contents = File.open(file.local_path, 'rb').read
        contents = Base64.strict_encode64(contents)
        document.merge!(:data => "data:#{mime_type(file.local_path)};base64,#{contents}")

        documents_to_sign << document

      end

      signers = []
      signatures.each do |signature|
        contents = File.open(signature.image_path, 'rb').read
        contents = Base64.strict_encode64(contents)
        signer = { :name => signature.name, :data => "data:#{mime_type(signature.image_path)};base64,#{contents}" }
        signer.merge!(signature.position)
        # place signature on is not implemented yet
        signer.merge!(:placeSignatureOn => nil)
        signer.merge!(:email => signature.email)

        signers << signer


      end

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = '/signature/{{client_id}}/sign'
        request[:request_body] = { :documents => documents_to_sign, :signers => signers }
      end.execute!
      json[:jobId]

    end

    #
    #  Get sign documents status
    #
    # @param [String] job_guid
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def document_status!(job_guid,  access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/documents/#{job_guid}"
      end.execute!

       json[:documents]
    end

    #
    # Returns a document metadata by given path.
    #
    # @param [String] path Full path to document
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document::View>]
    #
    def self.metadata!(path, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{path}"
      end.execute!

      Document::MetaData.new do |metadata|
        metadata.id = json[:id]
        metadata.guid = json[:guid]
        metadata.page_count = json[:page_count]
        metadata.views_count = json[:views_count]
        if json[:last_view]
          metadata.last_view = json[:last_view]
        end
      end
    end

    # @attr [GroupDocs::Storage::File] file
    attr_accessor :file
    # @attr [Time] process_date
    attr_accessor :process_date
    # @attr [Array<GroupDocs::Storage::File>] outputs
    attr_accessor :outputs
    # @attr [Array<Symbol>] output_formats
    attr_accessor :output_formats
    # @attr [Symbol] status
    attr_accessor :status
    # @attr [Integer] order
    attr_accessor :order
    # @attr [Integer] field_count
    attr_accessor :field_count

    #added in release 1.6.0
    # @attr [String] fieldType
    attr_accessor :fieldType
    # @attr [Int] dependent_questionnaires_count
    attr_accessor :dependent_questionnaires_count
    # @attr [Long] upload_time
    attr_accessor :upload_time

    [
        :news                            ,
        :alerts                          ,
        :support                         ,
        :is_real_time_broadcast          ,
        :is_scroll_broadcast             ,
        :is_zoom_broadcast               ,
        :is_annotation_navigation_widget ,
        :is_annotation_zoom_widget       ,
        :is_annotation_download_widget   ,
        :is_annotation_print_widget      ,
        :is_annotation_help_widget       ,
        :is_right_panel                  ,
        :is_thumbnails_panel             ,
        :is_toolbar                      ,
        :is_text_annotation_button       ,
        :is_rectangle_annotation_button  ,
        :is_point_annotation_button      ,
        :is_strikeout_annotation_button  ,
        :is_polyline_annotation_button   ,
        :is_typewriter_annotation_button ,
        :is_watermark_annotation_button  ,
        :is_viewer_navigation_widget     ,
        :is_viewer_zoom_widget           ,
        :is_viewer_download_widget       ,
        :is_viewer_print_widget          ,
        :is_viewer_help_widget           ,
    ].each do |option|
      # @attr [Boolean] option
      attr_accessor :"#{option}_enabled"
    end
    [
        :standard_header_always   ,
        :annotation_document_name ,
        :viewer_document_name     ,
    ].each do |option|
      # @attr [Boolean] option
      attr_accessor :"is_#{option}_shown"
    end

    #
    # Coverts passed array of attributes hash to array of GroupDocs::Storage::File.
    #
    # @param [Array<Hash>] outputs Array of file attributes hashes
    #
    def outputs=(outputs)
      if outputs
        @outputs = outputs.map do |output|
          GroupDocs::Storage::File.new(output)
        end
      end
    end

    #
    # Returns output formats in human-readable format.
    #
    # @return [Array<Symbol>]
    #
    def output_formats
      @output_formats.split(',').map(&:to_sym)
    end

    #
    # Converts status to human-readable format.
    #
    # @return [Symbol]
    #
    def status
      parse_status(@status)
    end

    #
    # Converts timestamp which is return by API server to Time object.
    #
    # @return [Time]
    #
    def process_date
      Time.at(@process_date / 1000)
    end

    # Compatibility with response JSON
    alias_method :proc_date=, :process_date=

    #
    # Creates new GroupDocs::Document.
    #
    # You should avoid creating documents directly. Instead, use #to_document
    # instance method of GroupDocs::Storage::File.
    #
    # @raise [ArgumentError] If file is not passed or is not an instance of GroupDocs::Storage::File
    #
    def initialize(options = {}, &blk)
      super(options, &blk)
      file.is_a?(GroupDocs::Storage::File) or raise ArgumentError,
                                                    "You have to pass GroupDocs::Storage::File object: #{file.inspect}."
    end

    #
    #  Returns a stream of bytes representing a particular document page image.
    #
    # @param [String] path Document path
    # @param [String] name Name document (format - jpg)
    # @example path = "#{File.dirname(__FILE__)}"
    #          name = "test.jpg"
    # @param [Integer] page_number Document page number to get image for
    # @param [Integer] dimension Image dimension "<width>x<height>"(500x600)
    # @param [Hash] options
    # @option options [Integer] :quality Image quality in range 1-100.
    # @option options [Boolean] :use_pdf A flag indicating whether a document should be converted to PDF format before generating the image.
    # @option options [Boolean] :expires  The date and time in milliseconds since epoch the URL expires.
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return []
    #
    def page_image!(path, name, page_number, dimension, options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DOWNLOAD
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/pages/#{page_number}/images/#{dimension}"
      end
      api.add_params(options)
      response = api.execute!

      filepath = "#{path}/#{name}"
      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath

    end






    #
    # Returns array of URLs to images representing document pages.
    #
    # @example
    #   file = GroupDocs::Storage::Folder.list!.last
    #   document = file.to_document
    #   document.page_images! 1024, 768, first_page: 0, page_count: 1
    #
    # @param [Integer] width Image width
    # @param [Integer] height Image height
    # @param [Hash] options
    # @option options [Integer] :first_page Start page to return image for (starting with 0)
    # @option options [Integer] :page_count Number of pages to return image for
    # @option options [Integer] :quality
    # @option options [Boolean] :use_pdf
    # @option options [Boolean] :token
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<String>]
    #
    def page_images!(width, height, options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/pages/images/#{width}x#{height}/urls"
      end
      api.add_params(options)
      json = api.execute!

      json[:url]
    end


    #
    # Returns editing metadata.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def editlock!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/editlock"
      end.execute!
    end

    #
    # Removes edit lock for a document and replaces the document with its edited copy
    #
    # @param [Hash] options
    # @option options [String] :lockId Start page to return image for (starting with 0)
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Integer]
    #
    def editlock_clear!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/editlock"
      end
      api.add_params(options).execute!
    end

    #
    # Returns tags assigned to the document
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<String>]
    #
    def tags!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/tags"
      end.execute!
    end

    #
    #  Assign tags to the document.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def tags_set!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/tags"
      end.execute!
    end

    #
    #   Removes tags assigned to the document
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def tags_clear!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/tags"
      end.execute!
    end

    #
    # Returns document content
    #
    # @param [String] content_type Content type
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def content!(content_type, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/content/#{content_type}"
      end.execute!

      json[:content]
    end

    #
    # Returns array of URLs to images representing document pages thumbnails.
    #
    # @example
    #   file = GroupDocs::Storage::Folder.list!.last
    #   document = file.to_document
    #   document.thumbnails! first_page: 0, page_count: 1, width: 1024
    #
    # @param [Hash] options
    # @option options [Integer] :page_number Start page to return image for (starting with 0)
    # @option options [Integer] :page_count Number of pages to return image for
    # @option options [Integer] :width
    # @option options [Integer] :quality
    # @option options [Boolean] :use_pdf
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<String>]
    #
    def thumbnails!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/thumbnails"
      end
      api.add_params(options)
      json = api.execute!

      json[:image_urls]
    end



    #
    # Returns access mode of document.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Symbol] One of :private, :restricted or :public access modes
    #
    def access_mode!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/accessinfo"
      end.execute!

      parse_access_mode(json[:access])
    end

    #
    # Sets access mode of document.
    #
    # @param [Symbol] mode One of :private, :restricted or :public access modes
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Symbol] Set access mode
    #
    def access_mode_set!(mode, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/doc/{{client_id}}/files/#{file.id}/accessinfo"
      end
      api.add_params(:mode => ACCESS_MODES[mode])
      json = api.execute!

      parse_access_mode(json[:access])
    end
    # note that aliased version cannot accept access credentials hash
    alias_method :access_mode=, :access_mode_set!

    #
    # Returns array of file formats document can be converted to.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<Symbol>]
    #
    def formats!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.id}/formats"
      end.execute!

      json[:types].map do |format|
        format.downcase.to_sym
      end
    end

    #
    # Returns document metadata.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Document::MetaData]
    #
    def metadata!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/metadata"
      end.execute!

      Document::MetaData.new do |metadata|
        metadata.id = json[:id]
        metadata.guid = json[:guid]
        metadata.page_count = json[:page_count]
        metadata.views_count = json[:views_count]
        if json[:last_view]
          metadata.last_view = json[:last_view]
        end
      end
    end

    #
    # Returns an array of document fields.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document::Field>]
    #
    def fields!(access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/fields"
      end
      api.add_params(:include_geometry => true)
      json = api.execute!

      json[:fields].map do |field|
        Document::Field.new(field)
      end
    end

    #
    # Returns an array of users a document is shared with.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def sharers!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.id}/accessinfo"
      end.execute!

      json[:sharers].map do |user|
        User.new(user)
      end
    end

    #
    # Returns an array of users a document is shared with.
    # @param [String] sharers_types
    # @param [Hash] options
    # @option options [String] :page_index
    # @option options [String] :page_size
    # @option options [String] :order_by
    # @option options [Boolean] :order_ask
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def shared_documents!(sharers_types, options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/shares/#{sharers_types}"
      end
      api.add_params(options).execute!

    end

    #
    # Sets document sharers to given emails.
    #
    # If empty array or nil passed, clears sharers.
    #
    # @param [Array] emails List of email addresses to share with
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def sharers_set!(emails, access = {})
      if emails.nil? || emails.empty?
        sharers_clear!(access)
      else
        json = Api::Request.new do |request|
          request[:access] = access
          request[:method] = :PUT
          request[:path] = "/doc/{{client_id}}/files/#{file.id}/sharers"
          request[:request_body] = emails
        end.execute!

        json[:shared_users].map do |user|
          User.new(user)
        end
      end
    end

    #
    # Sets document password.
    #
    # @param [String] password New password for document
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def password_set!(password, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/password"
        request[:request_body] = password
      end.execute!

    end

    #
    # Sets document user status.
    #
    # @param [String] status
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def user_status_set!(status, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/sharer"
        request[:request_body] = status
      end.execute!

    end

    #
    # Clears sharers list.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return nil
    #
    def sharers_clear!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/doc/{{client_id}}/files/#{file.id}/sharers"
      end.execute![:shared_users]

    end

    #
    # Converts document to given format.
    #
    # @example
    #   document = GroupDocs::Storage::Folder.list!.first.to_document
    #   job = document.convert!(:docx)
    #   sleep(5) # wait for server to finish converting
    #   original_document = job.documents![:inputs].first
    #   converted_file = original_file.outputs.first
    #   converted_file.download!(File.dirname(__FILE__))
    #
    # @param [Symbol] format
    # @param [Hash] options
    # @option options [Boolean] :email_results
    # @option options [String] :new_description
    # @option options [String] :print_script
    # @option options [String] :callback
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Job] Created job
    #
    def convert!(format, options = {}, access = {})
      options.merge!(:new_type => format)

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/async/{{client_id}}/files/#{file.guid}"
      end
      api.add_params(options)
      json = api.execute!

      Job.new(:id => json[:job_id])
    end

    #
    # Creates new job to merge datasource into document.
    #
    # @param [GroupDocs::DataSource] datasource
    # @param [Hash] options
    # @option options [Boolean] :new_type New file format type
    # @option options [Boolean] :email_results Set to true if converted document should be emailed
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Job]
    #
    # @raise [ArgumentError] if datasource is not GroupDocs::DataSource object
    #
    def datasource!(datasource, options = {}, access = {})
      datasource.is_a?(GroupDocs::DataSource) or raise ArgumentError,
                                                       "Datasource should be GroupDocs::DataSource object, received: #{datasource.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/datasources/#{datasource.id}"
      end
      api.add_params(options)
      json = api.execute!

      Job.new(:id => json[:job_id])
    end

    #
    # Creates new job to merge datasource fields into document.
    #
    # @param [GroupDocs::DataSource] datasource
    # @param [Hash] options
    # @option options [Boolean] :new_type New file format type
    # @option options [Boolean] :email_results Set to true if converted document should be emailed
    # @option options [Boolean] :assembly_name
    # @param [Array] datasourceFields (:name [String], :value [String], :contentType [String], :type [String], :nested_fields [<Array> datasourceFields])
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Job]
    #
    # @raise [ArgumentError] if datasource is not GroupDocs::DataSource object
    #
    def datasource_fields!(datasource, options = {}, access = {})
      datasource.is_a?(GroupDocs::DataSource) or raise ArgumentError,
                                                       "Datasource should be GroupDocs::DataSource object, received: #{datasource.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/datasources"
        request[:request_body] = datasource.fields
      end
      api.add_params(options)
      json = api.execute!

      Job.new(:id => json[:job_id])
    end


    #
    # Returns an array of questionnaires.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Questionnaire>]
    #
    def questionnaires!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/questionnaires"
      end.execute!

      json[:questionnaires].map do |questionnaire|
        Questionnaire.new(questionnaire)
      end
    end

    #
    # Adds questionnaire to document.
    #
    # @param [GroupDocs::Questionnaire] questionnaire
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    # @raise [ArgumentError] if questionnaire is not GroupDocs::Questionnaire object
    #
    def add_questionnaire!(questionnaire, access = {})
      questionnaire.is_a?(GroupDocs::Questionnaire) or raise ArgumentError,
                                                             "Questionnaire should be GroupDocs::Questionnaire object, received: #{questionnaire.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/questionnaires/#{questionnaire.id}"
      end.execute!
    end

    #
    # Creates questionnaire and adds it to document.
    #
    # @param [GroupDocs::Questionnaire] questionnaire
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Questionnaire]
    #
    # @raise [ArgumentError] if questionnaire is not GroupDocs::Questionnaire object
    #
    def create_questionnaire!(questionnaire, access = {})
      questionnaire.is_a?(GroupDocs::Questionnaire) or raise ArgumentError,
                                                             "Questionnaire should be GroupDocs::Questionnaire object, received: #{questionnaire.inspect}"

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/questionnaires"
        request[:request_body] = questionnaire.to_hash
      end.execute!

      questionnaire.id = json[:questionnaire_id]
      questionnaire
    end

    #
    # Detaches questionnaire from document.
    #
    # @param [GroupDocs::Questionnaire] questionnaire
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    # @raise [ArgumentError] if questionnaire is not GroupDocs::Questionnaire object
    #
    def remove_questionnaire!(questionnaire, access = {})
      questionnaire.is_a?(GroupDocs::Questionnaire) or raise ArgumentError,
                                                             "Questionnaire should be GroupDocs::Questionnaire object, received: #{questionnaire.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/questionnaires/#{questionnaire.id}"
      end.execute!
    end

    #
    # Returns an array of annotations.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document::Annotation>]
    #
    def annotations!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/annotations"
      end.execute!

      if json[:annotations]
        json[:annotations].map do |annotation|
          annotation.merge!(:document => self)
          Document::Annotation.new(annotation)
        end
      else
        []
      end
    end

    #
    # Changed in release 1.5.8
    # Returns document details.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Hash]
    #
    def details!(access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/comparison/{{client_id}}document"
      end
      api.add_params(:guid => file.guid)
      api.execute!
    end

    #
    # Changed in release 1.5.8
    # Schedules a job for comparing document with given.
    #
    # @param [GroupDocs::Document] document
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Job]
    #
    # @raise [ArgumentError] if document is not GroupDocs::Document object
    #
    def compare!(document, callback, access = {})
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
                                                   "Document should be GroupDocs::Document object, received: #{document.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/comparison/{{client_id}}/compare"
      end
      api.add_params(:source => file.guid, :target => document.file.guid, :callback => callback)
      json = api.execute!

      Job.new(:id => json[:job_id])
    end

    #
    # Schedules a job for comparing document with given.
    #
    # @param [Array] changes  Comparison changes to update (accept or reject)
    # @option id [Float] :id
    # @option type [String] :type
    # @option action [String] :action
    # @option Page [Array] :page
    # @option box [Array] :box
    # @option text [String] :text
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Change]
    #
    def update_changes!(changes, access = {})

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/comparison/public/#{file.guid}/changes"
        request[:request_body] = changes
      end
      json = api.execute!

      json[:changes].map do |change|
        Document::Change.new(change)
      end
    end

    #
    # @Changed in release 1.5.9
    # Returns an array of changes in document.
    #
    # @example
    #   document_one = GroupDocs::Storage::Folder.list![0].to_document
    #   document_two = GroupDocs::Storage::Folder.list![1].to_document
    #   job = document_one.compare!(document_two)
    #   sleep(5) # wait for server to finish comparing
    #   result = job.documents![:outputs].first
    #   result.changes!
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def changes!(access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/comparison/public/#{file.guid}/changes"
      end
      json = api.execute!

      json[:changes].map do |change|
        Document::Change.new(change)
      end
    end

    #
    # Changed in release 1.5.8
    # Download comparison result file.
    #
    # @example
    #  document_one = GroupDocs::Storage::Folder.list![0].to_document
    #  document_two = GroupDocs::Storage::Folder.list![1].to_document
    #  job = document_one.compare!(document_two)
    #  sleep(5) # wait for server to finish comparing
    #  result = job.documents![:outputs].first
    #  result.download!("#{File.dirname(__FILE__)}", {:format => 'pdf'})
    #
    # @param [Hash] options
    # @option format [String] :format Comparison result file GUID    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    #
    def download!( path, options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DOWNLOAD
        request[:path] = "/comparison/public/#{file.guid}/download"
      end
      api.add_params(options)
      response = api.execute!

      if file.name.split('.').last != options[:format]
        file_name = file.name.delete!(file.name.split('.').last) +  options[:format]
      else
        file_name = file.name
      end
      filepath = "#{path}/#{file_name}"
      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

    end

    #
    # Returns document annotations collaborators.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def collaborators!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/collaborators"
      end.execute!

      json[:collaborators].map do |collaborator|
        User.new(collaborator)
      end
    end

    #
    # Sets document annotations collaborators to given emails.
    #
    # @param [Array<String>] emails List of collaborators' email addresses
    # @param [Integer] version Annotation version
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def set_collaborators!(emails, version = 1, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/version/#{version}/collaborators"
        request[:request_body] = emails
      end.execute!

      json[:collaborators].map do |collaborator|
        User.new(collaborator)
      end
    end

    #
    # Adds document annotations collaborator.
    #
    # @param [GroupDocs::User] collaborator
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def add_collaborator!(collaborator, access = {})
      collaborator.is_a?(GroupDocs::User) or raise ArgumentError,
                                                   "Collaborator should be GroupDocs::User object, received: #{collaborator.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/collaborators"
        request[:request_body] = collaborator.to_hash
      end.execute!
    end


    #
    #  Delete document reviewer
    #
    # @param [String] reviewerId Reviewer Id
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def remove_collaborators!(reviewerId, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/collaborators/#{reviewerId}"
      end.execute!

    end

    #
    # Sets reviewers for document.
    #
    # @example Change reviewer rights
    #   reviewers = document.collaborators!
    #   reviewers.each do |reviewer|
    #     reviewer.access_rights = %w(view)
    #   end
    #   document.set_reviewers! reviewers
    #
    # @param [Array<GroupDocs::User>] reviewers
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def set_reviewers!(reviewers, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/reviewerRights"
        request[:request_body] = reviewers.map(&:to_hash)
      end.execute!
    end

    #
    # Returns an array of access rights for shared link.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<Symbol>]
    #
    def shared_link_access_rights!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/sharedLinkAccessRights"
      end.execute!

      if json[:accessRights]
        convert_byte_to_access_rights json[:accessRights]
      else
        []
      end
    end

    #
    # Sets access rights for shared link.
    #
    # @param [Array<Symbol>] rights
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<Symbol>]
    #
    def set_shared_link_access_rights!(rights, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/sharedLinkAccessRights"
        request[:request_body] = convert_access_rights_to_byte(rights)
      end.execute!
    end

    #
    # Sets session callback URL.
    #
    # @param [String] url Callback URL
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def set_session_callback!(url, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/files/#{file.guid}/sessionCallbackUrl"
        request[:request_body] = url
      end.execute!
    end

    #
    # Pass all unknown methods to file.
    #


    def method_missing(method, *args, &blk)
      file.respond_to?(method) ? file.send(method, *args, &blk) : super
    end

    def respond_to?(method)
      super or file.respond_to?(method)
    end


    #
    # added in release 1.5.8
    #
    # Returns document hyperlinks
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def hyperlinks!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/hyperlinks"
      end.execute!

      json[:links]
    end

    #
    # Changed in release 1.5.8
    #
    #
    # Public Sign document
    #
    # @param [String] document Document GUID
    # @param [Hash] settings Settings of the signing document
    # @param settings [String] waterMarkText
    # @param settings [String] waterMarkImage
    # @param settings [String] name (required)
    # @param settings [Double] top (required)
    # @param settings [Double] left (required)
    # @param settings [Double] width (required)
    # @param settings [Double] height (required)
    # @param settings [String] placeSignatureOn (required)
    # @param settings [String] data
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def public_sign_document!(options = {}, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/signature/public/documents/#{file.guid}/sign"
        request[:request_body] = options
      end.execute!

      json[:jobId]
    end

    #
    # Changed in release 1.5.8
    #
    #
    # Get document fields
    #
    # @param [String] document Document GUID
    # @param [Hash] settings Settings of the signing document
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.public_fields!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/documents/#{file.guid}/fields"
      end.execute!
    end

    # added in release 1.7.0
    #
    # Get template fields.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def editor_fields!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/doc/{{client_id}}/files/#{file.guid}/editor_fields"
      end.execute!
      json[:fields].map do |field|
        TemplateEditorFields.new(field)
      end
    end

    # added in release 1.7.0
    #
    # Create questionnaire template from file.
    #
    #  @example
    #
    # file = GroupDocs::Storage::File.new({:guid => '3be4e06494caed131d912c75e17d5f22592e3044032e0f81b35f13a8c9fefb49'}).to_document
    # field = GroupDocs::Document::TemplateEditorFields.new
    # field.name = 'test'
    # field.fieldtype = 'TextBox'
    # field.page = 1
    # file.questionnaire_template!([field] )
    #
    #
    # @param List[GroupDocs::Document::TemplateEditorFields] fields
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def questionnaire_template!(fields, access = {})

      fields.each do |field|
        field.is_a?(GroupDocs::Document::TemplateEditorFields) or raise ArgumentError,
                                                                        "Fields should be List GroupDocs::Document::TemplateEditorFields objects, received: #{fields.inspect}"
      end

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/templates"
        request[:request_body] = fields
      end.execute!
      json[:templateFields].map do |field|
        Document::Field.new(field)
      end
    end

    # added in release 1.8.0
    #
    # Add template editor fields to the specific document
    #
    #  @example
    #
    # file = GroupDocs::Storage::File.new({:guid => '3be4e06494caed131d912c75e17d5f22592e3044032e0f81b35f13a8c9fefb49'}).to_document
    # field = GroupDocs::Document::TemplateEditorFields.new
    # field.name = 'test'
    # field.fieldtype = 'TextBox'
    # field.page = 1
    # file.add_questionnaire_template!([field] )
    #
    #
    # @param List[GroupDocs::Document::TemplateEditorFields] fields
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def add_questionnaire_template!(fields, access = {})

      fields.each do |field|
        field.is_a?(GroupDocs::Document::TemplateEditorFields) or raise ArgumentError,
                                                                        "Fields should be List GroupDocs::Document::TemplateEditorFields objects, received: #{fields.inspect}"
      end

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/templates/add"
        request[:request_body] = fields
      end.execute!
      json[:templateFields].map do |field|
        Document::Field.new(field)
      end
    end


    # added in release 1.8.0
    #
    # Update template's fields
    #
    #  @example
    #
    # file = GroupDocs::Storage::File.new({:guid => '3be4e06494caed131d912c75e17d5f22592e3044032e0f81b35f13a8c9fefb49'}).to_document
    # field = GroupDocs::Document::TemplateEditorFields.new
    # field.name = 'test'
    # field.fieldtype = 'TextBox'
    # field.page = 1
    # file.update_questionnaire_template!([field] )
    #
    #
    # @param List[GroupDocs::Document::TemplateEditorFields] fields
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def update_questionnaire_template!(fields, access = {})

      fields.each do |field|
        field.is_a?(GroupDocs::Document::TemplateEditorFields) or raise ArgumentError,
                                                                        "Fields should be List GroupDocs::Document::TemplateEditorFields objects, received: #{fields.inspect}"
      end

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/templates/update"
        request[:request_body] = fields
      end.execute!
      json[:templateFields].map do |field|
        Document::Field.new(field)
      end
    end

    # added in release 1.8.0
    #
    # Delete template's fields
    #
    #  @example
    #
    # file = GroupDocs::Storage::File.new({:guid => '3be4e06494caed131d912c75e17d5f22592e3044032e0f81b35f13a8c9fefb49'}).to_document
    # field = file.editor_fields!
    # file.delete_questionnaire_template!([field] )
    #
    #
    # @param List[GroupDocs::Document::TemplateEditorFields] fields
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def delete_questionnaire_template!(fields, access = {})

      fields.each do |field|
        field.is_a?(GroupDocs::Document::TemplateEditorFields) or raise ArgumentError,
                                                                        "Fields should be List GroupDocs::Document::TemplateEditorFields objects, received: #{fields.inspect}"
      end

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}/files/#{file.guid}/templates/delete"
        request[:request_body] = fields
      end.execute!
      json[:templateFields].map do |field|
        Document::Field.new(field)
      end
    end

  end # Document
end # GroupDocs
