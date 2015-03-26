module GroupDocs
  class Document::Change < Api::Entity

    # @attr [Integer] id
    attr_accessor :id
    # @attr [Symbol] type
    attr_accessor :type
    # @attr [GroupDocs::Document::Rectangle] box
    attr_accessor :box
    # @attr [String] text
    attr_accessor :text
    # @attr [GroupDocs::Document::Page] page
    attr_accessor :page


    #Added in release 2.1.0
    # @attr [String] type
    attr_accessor :type
    # @attr [String] typeStr
    attr_accessor :typeStr
    # @attr [String] action
    attr_accessor :action
    # @attr [String] actionStr
    attr_accessor :actionStr

    #
    # Returns type as symbol.
    #
    # @return [Symbol]
    #
    def type
      @type.to_sym
    end

    #
    # Coverts passed hash to GroupDocs::Document::Rectangle object.
    #
    # @param [Hash] options
    # @return [GroupDocs::Document::Rectangle]
    #
    def box=(options)
      @box = GroupDocs::Document::Rectangle.new(options)
    end

    #
    # Coverts passed hash to GroupDocs::Document::Page object.
    #
    # @param [Hash] options
    # @return [GroupDocs::Document::Page]
    #
    def page=(options)
      @page = GroupDocs::Document::Page.new(options)
    end

  end # Document::Change
end # GroupDocs
