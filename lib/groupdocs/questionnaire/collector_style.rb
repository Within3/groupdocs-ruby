# added in release 1.7.0
module GroupDocs
  class Questionnaire::QuestionnaireCollectorStyle < Api::Entity
    require 'groupdocs/questionnaire/style/title'
    require 'groupdocs/questionnaire/style/base_font'
    require 'groupdocs/questionnaire/style/question_title'

    # @attr [String] page
    attr_accessor :collectorId
    # @attr [GroupDocs::Questionnaire::Rectangle] title
    attr_accessor :title
    # @attr [GroupDocs::Questionnaire::Rectangle] questionTitle
    attr_accessor :questionTitle
    # @attr [GroupDocs::Questionnaire::Rectangle] baseFont
    attr_accessor :baseFont

    #
    # Converts passed hash to GroupDocs::Questionnaire::QuestionnaireCollectorStyle::Title object.
    # @param [Hash] options
    #
    def title=(title)
      if title.is_a?(Hash)
        title = GroupDocs::Questionnaire::QuestionnaireCollectorStyle::Title.new(title)
      end

      @title = title
    end

    #
    # Converts passed hash to GroupDocs::Questionnaire::QuestionnaireCollectorStyle::QuestionTitle object.
    # @param [Hash] options
    #
    def questionTitle=(questionTitle)
      if questionTitle.is_a?(Hash)
        questionTitle = GroupDocs::Questionnaire::QuestionnaireCollectorStyle::QuestionTitle.new(questionTitle)
      end

      @questionTitle = questionTitle
    end
    #
    # Converts passed hash to GroupDocs::Questionnaire::QuestionnaireCollectorStyle::BaseFont object.
    # @param [Hash] options
    #
    def baseFont=(baseFont)
      if baseFont.is_a?(Hash)
        baseFont = GroupDocs::Questionnaire::QuestionnaireCollectorStyle::BaseFont.new(baseFont)
      end

      @baseFont = baseFont
    end


  end # Document::QuestionnaireCollectorStyle
end # GroupDocs
