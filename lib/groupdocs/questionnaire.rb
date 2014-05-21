module GroupDocs
  class Questionnaire < Api::Entity

    require 'groupdocs/questionnaire/collector'
    require 'groupdocs/questionnaire/execution'
    require 'groupdocs/questionnaire/page'
    require 'groupdocs/questionnaire/question'

    include Api::Helpers::Status

    #
    # Returns an array of all questionnaires.
    #
    # @param [Hash] options Hash of options
    # @option options [Symbol] :status Filter questionnaires by status
    # @option options [Integer] :page_number Page to start with
    # @option options [Integer] :page_size How many items to list
    # @option options [String] :orderBy Order by column (optional)
    # @option options [Bool] :isAscending Order by ascending or descending (optional)
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Questionnaire>]
    #
    def self.all!(options = {}, access = {})
      if options[:status]
        # TODO find better way to parse status
        options[:status] = new.send(:parse_status, options[:status])
      end

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/merge/{{client_id}}/questionnaires'
      end
      api.add_params(options)
      json = api.execute!

      json[:questionnaires].map do |questionnaire|
        new(questionnaire)
      end
    end

    #
    # Returns questionnaire by identifier.
    #
    # @param [Integer] id
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Questionnaire, nil]
    #
    def self.get!(id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/questionnaires/#{id}"
      end.execute!

      new(json[:questionnaire])
    rescue RestClient::ResourceNotFound
      nil
    end

    # @attr [Integer] id
    attr_accessor :id
    # @attr [String] guid
    attr_accessor :guid
    # @attr [String] name
    attr_accessor :name
    # @attr [Symbol] status
    attr_accessor :status
    # @attr [String] descr
    attr_accessor :descr
    # @attr [Array<GroupDocs::Questionnaire::Page>] pages
    attr_accessor :pages
    # @attr [Integer] resolved_executions
    attr_accessor :resolved_executions
    # @attr [Integer] assigned_questions
    attr_accessor :assigned_questions
    # @attr [Integer] total_questions
    attr_accessor :total_questions
    # @attr [Integer] modified
    attr_accessor :modified
    # @attr [Integer] expires
    attr_accessor :expires
    # @attr [Array<String>] document_ids
    attr_accessor :document_ids

    # added in release 1.5.8
    #
    # @attr [Array<String>] formats
    attr_accessor :formats
    # @attr [String] folder
    attr_accessor :folder
    # @attr [String] emails
    attr_accessor :emails
    # @attr [String] output_format
    attr_accessor :output_format
    # @attr [Boolean] open_on_completion
    attr_accessor :open_on_completion
    # @attr [Integer] allowed_operations
    attr_accessor :allowed_operations

    # added in release 1.6.0
    # @attr [Integer] totalCount
    attr_accessor :totalCount


    # Human-readable accessors
    alias_accessor :description, :descr

    # added in release 1.6.0
    alias_accessor :total_count, :totalCount

    #
    # Converts each page to GroupDocs::Questionnaire::Page object.
    #
    # @param [Array<GroupDocs::Questionnaire::Page, Hash>] pages
    #
    def pages=(pages)
      if pages
        @pages = pages.map do |page|
          if page.is_a?(GroupDocs::Questionnaire::Page)
            page
          else
            Questionnaire::Page.new(page)
          end
        end
      end
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
    # Adds page to questionnaire.
    #
    # @param [GroupDocs::Questionnaire::Page] page
    # @raise [ArgumentError] if page is not GroupDocs::Questionnaire::Page object
    #
    def add_page(page)
      page.is_a?(GroupDocs::Questionnaire::Page) or raise ArgumentError,
        "Page should be GroupDocs::Questionnaire::Page object, received: #{page.inspect}"

      @pages ||= Array.new
      @pages << page
    end


    #
    # Creates questionnaire.
    #
    #  @example
    #
    # questionnaire = GroupDocs::Questionnaire.new()
    # pages = GroupDocs::Questionnaire::Page.new()
    # questions = GroupDocs::Questionnaire::Question.new()
    # answer = GroupDocs::Questionnaire::Question::Answer.new()
    # questions.answers = [answer]
    # conditions = GroupDocs::Questionnaire::Question::Conditions.new()
    # questions.conditions = [conditions]
    # pages.questions = [questions]
    # questionnaire.pages = [pages]
    # questionnaire.create!
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def create!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = '/merge/{{client_id}}/questionnaires'
        request[:request_body] = to_hash
      end.execute!

      self.id = json[:questionnaire_id]
      self.guid = json[:questionnaire_guid]
      self.name = json[:adjusted_name]
    end

    #
    # Updates questionnaire.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def update!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/merge/{{client_id}}/questionnaires/#{id}"
        request[:request_body] = to_hash
      end.execute!
    end

    #
    # Removes questionnaire.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def remove!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}/questionnaires/#{id}"
      end.execute!
    # TODO: fix this in API - http://scotland.groupdocs.com/jira/browse/CORE-391
    rescue RestClient::BadRequest
      nil
    end

    #
    # Returns array of datasources for questionnaire.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::DataSource>]
    #
    def datasources!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/questionnaires/#{id}/datasources"
      end.execute!

      json[:datasources].map do |datasource|
        DataSource.new(datasource)
      end
    end

    #
    # Returns an array of questionnaire executions.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Questionnaire::Execution>]
    #
    def executions!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/questionnaires/#{guid}/executions"
      end.execute!

      json[:executions].map do |execution|
        Execution.new(execution)
      end
    end

    #
    # Changed in release 1.5.8
    #
    #
    # Returns an array of questionnaire collectors.
    #
    #
    # @param [Hash] options Options
    # @option options [String] :orderBy Order by column (required)
    # @option options [Boolean] :isAsc Order by ascending or descending (required)
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Questionnaire::Collector>]
    #
    def collectors!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/questionnaires/#{guid}/collectors"
      end
        api.add_params(options)
        json = api.execute!

      json[:collectors].map do |collector|
        collector.merge!(:questionnaire => self)
        Collector.new(collector)
      end
    end

    #
    # Returns questionnaire metadata.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::Questionnaire]
    #
    def metadata!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/questionnaires/#{guid}/metadata"
      end.execute!

      Questionnaire.new(json[:questionnaire])
    end

    #
    # Updates questionnaire metadata.
    #
    # @example
    #   questionnaire = GroupDocs::Questionnaire.get!(1)
    #   metadata = questionnaire.metadata!
    #   metadata.name = 'New questionnaire name'
    #   questionnaire.update_metadata! metadata
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if metadata is not GroupDocs::Questionnaire
    #
    def update_metadata!(metadata, access = {})
      metadata.is_a?(GroupDocs::Questionnaire) or raise ArgumentError,
        "Metadata should be GroupDocs::Questionnaire object, received: #{metadata.inspect}"

      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/merge/{{client_id}}/questionnaires/#{guid}/metadata"
        request[:request_body] = metadata.to_hash
      end.execute!
    end

    #
    # Returns an array of document fields for questionnaire.
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
        request[:path] = "/merge/{{client_id}}/questionnaires/#{guid}/fields"
      end
      api.add_params(:include_geometry => true)
      json = api.execute!

      json[:fields].map do |field|
        Document::Field.new(field)
      end
    end
	
	  #
    # Changed in release 1.5.8
    #
    # Copy file to given path.
    #
    # @param [String] path (required)
    # @param [String] mode Mode (optional)
    # @param [Hash] options
    # @option options [String] name
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array] Templates
    #
    def copy_to_templates!(path, mode, options = {}, access = {})
      options[:name] ||= name
      path = prepare_path("#{path}/#{options[:name]}")

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:headers] = { :'Groupdocs-Copy' => id }
        request[:path] = "/merge/{{client_id}}/files/#{path}"
      end
      api.add_params(:mode => mode)
      json = api.execute!

      json[:templates]
    end


    #
    # Added in release 1.5.8
    #
    # Get associated document by questionnaire
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def get_document!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/merge/{{client_id}}/questionnaires/#{id}/document"
      end.execute!
    end

    #
    # Added in release 1.5.8
    #
    # Returns an array of questionnaires by name.
    #
    # @param [Hash] options Hash of options
    # @option options [String] :name Questionnaire name
    # @option options [Symbol] :status Filter questionnaires by status
    # @option options [Integer] :page_number Page to start with
    # @option options [Integer] :page_size How many items to list
    # @option options [String] :orderBy Order by column (optional)
    # @option options [Bool] :isAscending Order by ascending or descending (optional)
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Questionnaire>]
    #
    def self.get_by_name!(options = {}, access = {})
      if options[:status]
        # TODO find better way to parse status
        options[:status] = new.send(:parse_status, options[:status])
      end

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/merge/{{client_id}}/questionnaires/filter'
      end

      api.add_params(options)
      json = api.execute!

      json[:questionnaires].map do |questionnaire|
        new(questionnaire)
      end
    end

    #
    # Added in release 1.5.8
    #
    # Delete list of questionnaires by GUIDs.
    #
    # @param [Hash] access Access credentials
    # @option guids [Array<String>] List of Questionnaires Guid
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def delete_list!(guids, access = {})
     api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}/questionnaires/list"
        request[:request_body] = guids
     end
     
     api.execute!
    end

    #
    # Added in release 1.5.8
    #
    # Removes questionnaire collector.
    #
    # @param [Hash] access Access credentials
    # @option collectors [Array<String>] List of Collectors Guid
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def delete_collectors_list!(collectors, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}/questionnaires/collectors/list"
        request[:request_body] = collectors
      end.execute!
    end

    #
    # Added in release 1.5.8
    #
    # Removes questionnaire execution.
    #
    # @param [Hash] access Access credentials
    # @option executions [Array<String>] List of Executions Guid
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def delete_executions_list!(executions, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}/questionnaires/executions/list"
        request[:request_body] = executions
      end.execute!
    end

    #
    # Added in release 1.5.8
    #
    # Delete list of datasource fields.
    #
    # @param [Hash] access Access credentials
    # @option datasource [Array<String>] List of Datasources Guid
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def delete_datasources_list!(datasources, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/merge/{{client_id}}datasources/list"
        request[:request_body] = datasources
      end.execute!
    end



  end # Questionnaire
end # GroupDocs
