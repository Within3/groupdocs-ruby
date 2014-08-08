module GroupDocs
  class DataSource::Field < Api::Entity

    # @attr [String] name
    attr_accessor :name
    # @attr [Integer] type
    attr_accessor :type
    # @attr [Array<String>] values
    attr_accessor :values

    # added in release 1.7.0
    # @attr [String] contentType
    attr_accessor :contentType
    # @attr [List<GroupDocs::DataSource::Field>] nested_fields
    attr_accessor :nested_fields
    # @attr [String] regionName
    attr_accessor :regionName
    # @attr [String] dimension
    attr_accessor :dimension
    #
    # Updates type with machine-readable format.
    #
    # @param [Symbol] type
    #
    def type=(type)
      @type = type.is_a?(Symbol) ? type.to_s.capitalize : type
    end

    #
    # Returns type in human-readable format.
    #
    # @return [Symbol]
    #
    def type
      @type.downcase.to_sym
    end

  end # DataSource::Field
end # GroupDocs
