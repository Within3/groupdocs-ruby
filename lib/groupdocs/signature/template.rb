module GroupDocs
  class Signature::Template < Api::Entity

    include Signature::DocumentMethods
    include Signature::EntityFields
    include Signature::EntityMethods
    include Signature::FieldMethods
    include Signature::RecipientMethods
    extend  Signature::ResourceMethods

    #
    # Changed in release 1.7.0
    #
    #
    # Returns a list of all templates.  
    #
    # @param [Hash] options Hash of options
    # @option options [Integer] :page Page to start with
    # @option options [Integer] :records How many items to list
    # @option options [String] :documentGuid Fitler templates by document originalMD5
    # @option options [String] :recipientName Filter templates by recipient nickname
    # @option options [String] :name Filter templates by signatureTemplate name
    # @option options [String] :tag Filter templates by tag
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature::Template>]
    #
    def self.all!(options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/{{client_id}}/templates'
      end
      api.add_params(options)
      json = api.execute!

      json[:templates].map do |template|
        new(template)
      end
    end

    # @attr [Integer] templateExpireTime
    attr_accessor :templateExpireTime

    #added in release 1.7.0
    # @attr [Double] fieldsCount
    attr_accessor :fieldsCount
    # @attr [Boolean] enableTypedSignature
    attr_accessor :enableTypedSignature
    # @attr [Boolean] enableUploadedSignature
    attr_accessor :enableUploadedSignature
    # @attr [String] tags
    attr_accessor :tags

    # Human-readable accessors
    alias_accessor :template_expire_time, :templateExpireTime

    #
    # Adds recipient to template.
    #
    # @example
    #   roles = GroupDocs::Signature::Role.get!
    #   template = GroupDocs::Signature::Template.get!("g94h5g84hj9g4gf23i40j")
    #   recipient = GroupDocs::Signature::Recipient.new
    #   recipient.nickname = 'John Smith'
    #   recipient.role_id = roles.detect { |role| role.name == "Signer" }.id
    #   template.add_recipient! recipient
    #
    # @param [GroupDocs::Signature::Recipient] recipient
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if recipient is not GroupDocs::Signature::Recipient
    #
    def add_recipient!(recipient, access = {})
      recipient.is_a?(GroupDocs::Signature::Recipient) or raise ArgumentError,
        "Recipient should be GroupDocs::Signature::Recipient object, received: #{recipient.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/signature/{{client_id}}/templates/#{id}/recipient"
      end
      api.add_params(:nickname => recipient.nickname,
                     :role     => recipient.role_id,
                     :order    => recipient.order)
      api.execute!
    end

    #
    # Modify recipient of template.
    #
    # @example
    #   roles = GroupDocs::Signature::Role.get!
    #   template = GroupDocs::Signature::Template.get!("g94h5g84hj9g4gf23i40j")
    #   recipient = template.recipients!.first
    #   recipient.nickname = 'John Smith'
    #   recipient.role_id = roles.detect { |role| role.name == "Signer" }.id
    #   template.modify_recipient! recipient
    #
    # @param [GroupDocs::Signature::Recipient] recipient
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @raise [ArgumentError] if recipient is not GroupDocs::Signature::Recipient
    #
    def modify_recipient!(recipient, access = {})
      recipient.is_a?(GroupDocs::Signature::Recipient) or raise ArgumentError,
        "Recipient should be GroupDocs::Signature::Recipient object, received: #{recipient.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/signature/{{client_id}}/templates/#{id}/recipient/#{recipient.id}"
      end
      api.add_params(:nickname => recipient.nickname, :role => recipient.role_id , :order => recipient.order)
      api.execute!
    end



  end # Signature::Template
end # GroupDocs
