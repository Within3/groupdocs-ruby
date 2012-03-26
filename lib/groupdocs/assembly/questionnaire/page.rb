module GroupDocs
  module Assembly
    class Questionnaire::Page < GroupDocs::Api::Entity

      # @attr [Integer] number
      attr_accessor :number
      # @attr [String] title
      attr_accessor :title
      # @attr [Array<GroupDocs::Assembly::Questionnaire::Question>] questions
      attr_accessor :questions

      #
      # Adds question to page.
      #
      # @param [GroupDocs::Assembly::Questionnaire::Question] question
      # @raise [ArgumentError] if question is not GroupDocs::Assembly::Questionnaire::Question object
      #
      def add_question(question)
        question.is_a?(GroupDocs::Assembly::Questionnaire::Question) or raise ArgumentError,
          "Question should be GroupDocs::Assembly::Questionnaire::Question object, received: #{question.inspect}"

        @questions ||= Array.new
        @questions << question
      end

    end # Questionnaire::Page
  end # Assembly
end # GroupDocs
