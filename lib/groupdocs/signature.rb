module GroupDocs
  class Signature < Api::Entity

    require 'groupdocs/signature/shared'
    require 'groupdocs/signature/contact'
    require 'groupdocs/signature/envelope'
    require 'groupdocs/signature/field'
    require 'groupdocs/signature/form'
    require 'groupdocs/signature/list'
    require 'groupdocs/signature/recipient'
    require 'groupdocs/signature/role'
    require 'groupdocs/signature/template'

    include Api::Helpers::MIME

    #
    # Returns a list of all user signatures.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature>]
    #
    def self.get!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/{{client_id}}/signatures'
      end.execute!

      json[:signatures].map do |signature|
        new(signature)
      end
    end


    # Get signature fields.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature>]
    #
    def self.get_list!( access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/{{client_id}}/fields'
      end.execute!

      json[:fields]
    end



    #
    #  Changed in release 1.5.8
    #
    #
    # Verify to document
    #
    # @param [String] path Path to document GUID
    # @param [Hash] settings Settings of the signing document
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.verify!(filepath, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/signature/public/verify"
        request[:request_body] = Object::File.new(filepath, 'rb')
      end.execute!
    end



    #
    # Changed in release 1.5.8
    #
    #
    # Sign document
    #
    # @param [String] job Job GUID
    # @param [Hash] options 
    # @option [Boolean] :public
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.sign_document_status!(job, options = {}, access = {})

        client_id = !!options[:public] ? 'public' : '{{client_id}}'
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/#{client_id}/documents/#{job}/status"
      end.execute!

      Storage::File.new(:guid => json[:documents][0][:documentId])
    end



    #
    # This method deleted from GroupDocs API
    #
    # Returns a list of all signatures for recipient.
    #
    # @param [GroupDocs::Signature::Recipient] recipient
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Signature>]
    #
    def self.get_for_recipient!(recipient, access = {})
      recipient.is_a?(GroupDocs::Signature::Recipient) or raise ArgumentError,
        "Recipient should be GroupDocs::Signature::Recipient object, received: #{recipient.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/signature/public/signatures'
      end
      api.add_params(:recipientId => recipient.id)
      json = api.execute!

      json[:signatures].map do |signature|
        new(signature)
      end
    end


    # @attr [String] id
    attr_accessor :id
    # @attr [String] userGuid
    attr_accessor :userGuid
    # @attr [String] recipientId
    attr_accessor :recipientId
    # @attr [String] name
    attr_accessor :name
    # @attr [String] companyName
    attr_accessor :companyName
    # @attr [String] position
    attr_accessor :position
    # @attr [String] firstName
    attr_accessor :firstName
    # @attr [String] lastName
    attr_accessor :lastName
    # @attr [String] fullName
    attr_accessor :fullName
    # @attr [String] textInitials
    attr_accessor :textInitials
    # @attr [String] signatureImageFileId
    attr_accessor :signatureImageFileId
    # @attr [String] initialsImageFileId
    attr_accessor :initialsImageFileId
    # @attr [String] signatureImageUrl
    attr_accessor :signatureImageUrl
    # @attr [String] initialsImageUrl
    attr_accessor :initialsImageUrl
    # @attr [String] signatureData
    attr_accessor :signatureData
    # @attr [String] initialsData
    attr_accessor :initialsData
    # @attr [String] createdTimeStamp
    attr_accessor :createdTimeStamp
    # @attr [String] image_path
    attr_accessor :image_path

    # Human-readable accessors
    alias_accessor :user_guid,               :userGuid
    alias_accessor :recipient_id,            :recipientId
    alias_accessor :company_name,            :companyName
    alias_accessor :first_name,              :firstName
    alias_accessor :last_name,               :lastName
    alias_accessor :full_name,               :fullName
    alias_accessor :text_initials,           :textInitials
    alias_accessor :signature_image_file_id, :signatureImageFileId
    alias_accessor :initials_image_file_id,  :initialsImageFileId
    alias_accessor :signature_image_url,     :signatureImageUrl
    alias_accessor :initials_image_url,      :initialsImageUrl
    alias_accessor :signature_data,          :signatureData
    alias_accessor :initials_data,           :initialsData
    alias_accessor :created_time_stamp,      :createdTimeStamp


    #
    # Creates signature.
    #
    # @example
    #   signature = GroupDocs::Signature.new
    #   signature.first_name = 'John'
    #   signature.last_name = 'Smith'
    #   signature.create! "John Smith's Signature"
    #
    # @param [String] title Signature title
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def create!(title, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = '/signature/{{client_id}}/signature'
        request[:request_body] = to_hash
      end
      api.add_params(:name => title)
      json = api.execute!

      self.id = json[:signature][:id]
    end


    #
    # This method deleted from GroupDocs API
    #
    # Creates signature for recipient.
    #
    # @param [GroupDocs::Signature::Recipient] recipient
    # @param [String] title Signature title
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def create_for_recipient!(recipient, title, access = {})
      recipient.is_a?(GroupDocs::Signature::Recipient) or raise ArgumentError,
        "Recipient should be GroupDocs::Signature::Recipient object, received: #{recipient.inspect}"

      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = '/signature/public/signature'
        request[:request_body] = to_hash
      end
      api.add_params(:name => title, :recipientId => recipient.id)
      json = api.execute!

      self.id = json[:signature][:id]
    end


    #
    # Deletes signature.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def delete!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/signature/{{client_id}}/signatures/#{id}"
      end.execute!
    end


    #
    # This method deleted from GroupDocs API
    #
    # Returns signature data.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def signature_data!(access = {})
      self.signature_data = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/signatures/signature/#{id}/signatureData"
      end.execute!
    end



    #
    # This method deleted from GroupDocs API
    #
    # Returns initials data.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def initials_data!(access = {})
      self.initials_data = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/signature/public/signatures/signature/#{id}/initialsData"
      end.execute!
    end

    # added in release 1.6.0
    TEMPLATE_TYPES = {
        :EnvelopeSentOwnerTemplate           => 1,
        :EnvelopeSentOtherTemplate           => 2,
        :EnvelopeCompletedTemplate           => 3,
        :EnvelopeSignedTemplate              => 4,
        :EnvelopeCancelledTemplate           => 5,
        :EnvelopeDeclinedTemplate            => 6,
        :EnvelopeFailedTemplate              => 7,
        :EnvelopeExpiredTemplate             => 8,
        :EnvelopeStepExpiredTemplate         => 9,
        :EnvelopeRecipientReminderTemplate   => 10,
        :FormSignedTemplate                  => 11
    }


    #
    # Added in release 1.6.0
    #
    #
    # Get default email template.
    #
    # @param [String] path Path to save new file
    # @param [String] name Name new file (file extension should be html)
    # @param [Int] template_type Template type
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.public_get_default_email_template!(path, name, template_type, access = {})
      response = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DOWNLOAD
        request[:path] = "/signature/public/email-template/#{template_type}/default"
      end.execute!


      filepath = "#{path}/#{name}."

      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

    #
    # Added in release 1.6.0
    #
    #
    # Get user email template.
    #
    # @param [String] path Path to save new file
    # @param [String] name Name new file (file extension should be html)
    # @param [Int] template_type Template type
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.get_email_template!(path, name, template_type, access = {})
      response = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DOWNLOAD
        request[:path] = "/signature/email-template/#{template_type}"
      end.execute!


      filepath = "#{path}/#{name}."

      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

  end # Signature
end # GroupDocs
