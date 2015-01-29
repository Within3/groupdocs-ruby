module GroupDocs
  class Document::MetaData < Api::Entity

    # @attr [Integer] id
    attr_accessor :id
    # @attr [String] guid
    attr_accessor :guid
    # @attr [Integer] page_count
    attr_accessor :page_count
    # @attr [Integer] views_count
    attr_accessor :views_count
    # @attr [Hash] last_view
    attr_accessor :last_view

    # added in release 2.0.0
    # @attr [String] type
    attr_accessor :type
    # @attr [String] url
    attr_accessor :url

    #
    # Coverts passed hash to GroupDocs::Document::View object.
    #
    # @param [Hash] options
    # @return [GroupDocs::Document::View]
    #
    def last_view=(options)
      @last_view = GroupDocs::Document::View.new(options)
    end

  end # Document::Metadata
end # GroupDocs
