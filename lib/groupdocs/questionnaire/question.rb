module GroupDocs
  class Questionnaire::Question < Api::Entity

    require 'groupdocs/questionnaire/question/answer'
    require 'groupdocs/questionnaire/question/conditions'

    TYPES = %w(GenericText MultipleChoice)

    # @attr [String] field
    attr_accessor :field
    # @attr [String] text
    attr_accessor :text
    # @attr [String] def_answer
    attr_accessor :def_answer
    # @attr [Boolean] required
    attr_accessor :required
    # @attr [Symbol] type
    attr_accessor :type
    # @attr [Array<Hash>] answers
    attr_accessor :answers

    #
    # added in release 1.5.8
    #
    # @attr [Boolean] disabled
    attr_accessor :disabled
    # @attr [Integer] max_length
    attr_accessor :max_length
    # @attr [GroupDocs::Document::Rectangle] rect
    attr_accessor :rect
    # @attr [Array<String>] acceptableValues
    attr_accessor :acceptableValues
    # @attr [Array<GroupDocs::Questionnaire::Question::Conditions>] conditions
    attr_accessor :conditions

    # added in release 1.7.0
    #
    # @attr [String] regionName
    attr_accessor :regionName
    ## @attr [String] hint
    attr_accessor :hint
    # @attr [Array<String>] dimension
    attr_accessor :dimension


    # Human-readable accessors
    alias_accessor :default_answer, :def_answer

    # added in release 1.5.8
    alias_accessor :acceptable_values, :acceptableValues

    #
    # Converts each answer to GroupDocs::Questionnaire::Question::Answer object.
    #
    # @param [Array<Hash>] answers
    #
    def answers=(answers)
      if answers
        @answers = answers.map do |answer|
          if answer.is_a?(GroupDocs::Questionnaire::Question::Answer)
            answer
          else
            Questionnaire::Question::Answer.new(answer)
          end
        end
      end
    end

    #
    # Adds answer to the question.
    #
    # @param [GroupDocs::Questionnaire::Question::Answer] answer
    # @raise [ArgumentError] if answer is not GroupDocs::Questionnaire::Question::Answer object
    #
    def add_answer(answer)
      answer.is_a?(GroupDocs::Questionnaire::Question::Answer) or raise ArgumentError,
        "Answer should be GroupDocs::Questionnaire::Question::Answer object, received: #{answer.inspect}"

      @answers ||= Array.new
      @answers << answer
    end

    #
    # Updates type with machine-readable format.
    #
    # @param [Symbol] type
    # @raise [ArgumentError] if type is unknown
    #
    def type=(type)
      if type.is_a?(Symbol)
        type = type.to_s.camelize
        TYPES.include?(type) or raise ArgumentError, "Unknown type: #{type.inspect}"
      end

      @type = type
    end

    #
    # Returns field type in human-readable format.
    #
    # @return [Symbol]
    #
    def type
      @type.underscore.to_sym
    end

  end # Questionnaire::Question
end # GroupDocs
