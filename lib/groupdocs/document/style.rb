# added in release 1.7.0
module GroupDocs
  class Document::TemplateEditorFieldStyle < Api::Entity

    # @attr [String] fontName
    attr_accessor :fontName
    # @attr [String] fontSize
    attr_accessor :fontSize
    # @attr [String] color
    attr_accessor :color
    # @attr [String] backgroundColor
    attr_accessor :backgroundColor
    # @attr [String] borderWidth
    attr_accessor :borderWidth
    # @attr [String] borderColor
    attr_accessor :borderColor
    # @attr [String] textAlignment
    attr_accessor :textAlignment

    # Human-readable accessors
    alias_accessor :font_name, :fontName
    alias_accessor :font_size, :fontSize
    alias_accessor :background_color, :backgroundColor
    alias_accessor :border_width, :borderWidth
    alias_accessor :border_color, :borderColor
    alias_accessor :text_alignment, :textAlignment


  end # Document::TemplateEditorFieldStyle
end # GroupDocs
