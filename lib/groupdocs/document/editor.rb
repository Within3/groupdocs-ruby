# added in release 1.7.0
module GroupDocs
  class Document::TemplateEditorFields < Api::Entity

    # @attr [Integer] page
    attr_accessor :page
    # @attr [String] name
    attr_accessor :name
    # @attr [String] type
    attr_accessor :type
    # @attr [GroupDocs::Document::Rectangle] rect
    attr_accessor :rect
    # @attr [String] fieldtype
    attr_accessor :fieldtype
    # @attr [Array] acceptableValues
    attr_accessor :acceptableValues
    # @attr [Int] selectionPosition
    attr_accessor :selectionPosition
    # @attr [Int] selectionLength
    attr_accessor :selectionLength
    # @attr [GroupDocs::Document::Style] style
    attr_accessor :style
    # @attr [Boolean] isTableMarker
    attr_accessor :isTableMarker

    #
    # Converts passed hash to GroupDocs::Document::Rectangle object.
    # @param [Hash] options
    #
    def rect=(rectangle)
      if rectangle.is_a?(Hash)
        rectangle = GroupDocs::Document::Rectangle.new(rectangle)
      end

      @rect = rectangle
    end
    #
    # Converts passed hash to GroupDocs::Document::TemplateEditorFieldStyle object.
    # @param [Hash] options
    #
    def style=(style)
      if style.is_a?(Hash)
        style = GroupDocs::Document::TemplateEditorFieldStyle.new(style)
      end

      @style = style
    end

    # Human-readable accessors
    alias_accessor :rectangle, :rect

  end # Document::TemplateEditorFields
end # GroupDocs
