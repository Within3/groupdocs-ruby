module GroupDocs
  class Signature::Recipient < Api::Entity

    STATUSES = {
      :none       => -1,
      :waiting    =>  0,
      :notified   =>  1,
      :delegated  =>  2,
      :rejected   =>  3,
      :signed     =>  4,
    }

    # @attr [String] id
    attr_accessor :id
    # @attr [String] email
    attr_accessor :email
    # @attr [String] firstName
    attr_accessor :firstName
    # @attr [String] lastName
    attr_accessor :lastName
    # @attr [String] nickname
    attr_accessor :nickname
    # @attr [String] roleId
    attr_accessor :roleId
    # @attr [String] order
    attr_accessor :order
    # @attr [Symbol] status
    attr_accessor :status

    # added in release 1.7.0

    # @attr [String] userGuid
    attr_accessor :userGuid
    # @attr [String] statusMessage
    attr_accessor :statusMessage
    # @attr [String] statusDateTime
    attr_accessor :statusDateTime
    # @attr [Double] delegatedRecipientId
    attr_accessor :delegatedRecipientId
    # @attr [String] signatureFingerprint
    attr_accessor :signatureFingerprint
    # @attr [String] signatureHost
    attr_accessor :signatureHost
    # @attr [String] signatureLocation
    attr_accessor :signatureLocation
    # @attr [String] signatureBrowser
    attr_accessor :signatureBrowser
    # @attr [String] embedUrl
    attr_accessor :embedUrl
    # @attr [String] comment
    attr_accessor :comment

    # Human-readable accessors
    alias_accessor :first_name,               :firstName
    alias_accessor :last_name,                :lastName
    alias_accessor :role_id,                  :roleId

    # added in release 1.7.0
    alias_accessor :user_guid,                 :userGuid
    alias_accessor :status_message,            :statusMessage
    alias_accessor :status_date_time,          :statusDateTime
    alias_accessor :delegated_recipient_id,    :delegatedRecipientId
    alias_accessor :signature_fingerprint,     :signatureFingerprint
    alias_accessor :signature_host,            :signatureHost
    alias_accessor :signature_location,        :signatureLocation
    alias_accessor :signature_browser,         :signatureBrowser
    alias_accessor :embed_url,                 :embedUrl


    #
    # Converts status to human-readable format.
    # @return [Symbol]
    #
    def status
      STATUSES.invert[@status]
    end

  end # Signature::Recipient
end # GroupDocs
