module GroupDocs
  class Document::Annotation < Api::Entity

    require 'groupdocs/document/annotation/reply'
    require 'groupdocs/document/annotation/reviewer'

    include Api::Helpers::AccessMode

    #AnnotationType = { Text: 0, Area: 1, Point: 2, TextStrikeout: 3, Polyline: 4, TextField: 5, Watermark: 6,  TextReplacement: 7, TextRemoval: 8 }

    # updateed in release 1.6.0
    TYPES  = %w(Text Area Point TextStrikeout Polyline TextField Watermark TextReplacement TextRemoval )

    # @attr [GroupDocs::Document] document
    attr_accessor :document
    # @attr [Integer] id
    attr_accessor :id
    # @attr [String] guid
    attr_accessor :guid
    # @attr [String] sessionGuid
    attr_accessor :sessionGuid
    # @attr [String] documentGuid
    attr_accessor :documentGuid
    # @attr [String] creatorGuid
    attr_accessor :creatorGuid
    # @attr [String] replyGuid
    attr_accessor :replyGuid
    # @attr [Time] createdOn
    attr_accessor :createdOn
    # @attr [Symbol] type
    attr_accessor :type
    # @attr [Symbol] access
    attr_accessor :access
    # @attr [GroupDocs::Document::Rectangle] box
    attr_accessor :box
    # @attr [Array<GroupDocs::Document::Annotation::Reply>] replies
    attr_accessor :replies
    # @attr [Hash] annotationPosition
    attr_accessor :annotationPosition
    #@attr [Double] AnnotationSizeInfo
    attr_accessor :width
    attr_accessor :height
    #@attr [String]TextFieldInfo
    attr_accessor :fieldText
    attr_accessor :fontFamily
    attr_accessor :fontSize
    #@attr [String]Font Color
    attr_accessor :fontColor

    #added in release 1.5.8
    #@attr [Int] pageNumber
    attr_accessor :pageNumber
    #@attr [Long] serverTime
    attr_accessor :serverTime
    #attr [Array]

    #added in release 1.6.0
    #@attr [Int] penColor
    attr_accessor :penColor
    #@attr [Int] penWidth
    attr_accessor :penWidth
    #@attr [Int] penStyle
    attr_accessor :penStyle
    #@attr [Int] creatorName
    attr_accessor :creatorName
    #@attr [Int] creatorEmail
    attr_accessor :creatorEmail


    # Compatibility with response JSON
    alias_method :annotationGuid=, :guid=

    # Human-readable accessors
    alias_accessor :session_guid,        :sessionGuid
    alias_accessor :document_guid,       :documentGuid
    alias_accessor :creator_guid,        :creatorGuid
    alias_accessor :reply_guid,          :replyGuid
    alias_accessor :created_on,          :createdOn
    alias_accessor :annotation_position, :annotationPosition
   
    #added in release 1.5.8
    alias_accessor :page_number,         :pageNumber
    alias_accessor :server_time,         :serverTime

    #added in release 1.6.0
    alias_accessor :pen_color,           :penColor
    alias_accessor :pen_width,           :penWidth
    alias_accessor :pen_style,           :penStyle
    alias_accessor :creator_name,        :creatorName
    alias_accessor :creator_email,       :creatorEmail

    #
    # Creates new GroupDocs::Document::Annotation.
    #
    # @raise [ArgumentError] If document is not passed or is not an instance of GroupDocs::Document
    #
    def initialize(options = {}, &blk)
      super(options, &blk)
      document.is_a?(GroupDocs::Document) or raise ArgumentError,
        "You have to pass GroupDocs::Document object: #{document.inspect}."
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
    # Returns type in human-readable format.
    #
    # @return [Symbol]
    #
    def type
      @type.underscore.to_sym
    end

    #
    # Converts access mode to machine-readable format.
    #
    # @param [Symbol] mode
    #
    def access=(mode)
      @access = (mode.is_a?(Symbol) ? parse_access_mode(mode) : mode)
    end

    #
    # Converts access mode to human-readable format.
    #
    # @return [Symbol]
    #
    def access
      parse_access_mode(@access)
    end

    #
    # Converts timestamp which is return by API server to Time object.
    #
    # @return [Time]
    #
    def created_on
      Time.at(@createdOn / 1000)
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
    # Converts each reply to GroupDocs::Document::Annotation::Reply object.
    #
    # @param [Array<GroupDocs::Document::Annotation::Reply, Hash>] replies
    #
    def replies=(replies)
      if replies
        @replies = replies.map do |reply|
          if reply.is_a?(GroupDocs::Document::Annotation::Reply)
            reply
          else
            reply.merge!(:annotation => self)
            Document::Annotation::Reply.new(reply)
          end
        end
      end
    end

    #
    # Adds reply to annotation.
    #
    # @param [GroupDocs::Document::Annotation::Reply] reply
    # @raise [ArgumentError] if reply is not GroupDocs::Document::Annotation::Reply object
    #
    def add_reply(reply)
      reply.is_a?(GroupDocs::Document::Annotation::Reply) or raise ArgumentError,
        "Reply should be GroupDocs::Document::Annotation::Reply object, received: #{reply.inspect}"

      @replies ||= Array.new
      @replies << reply
    end

    #
    # Creates new annotation.
    #
    # @example
    #   document = GroupDocs::Storage::Folder.list!.first.to_document
    #   annotation = GroupDocs::Document::Annotation.new(document: document)
    #   annotation.create!
    #
    # @param [Hash] info Annotation info
    # @option info [Array] :box
    # @option info [Array] :annotationPosition
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def create!(info, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/ant/{{client_id}}/files/#{document.file.guid}/annotations"
        request[:request_body] = info
      end.execute!

      json.each do |field, value|
        send(:"#{field}=", value) if respond_to?(:"#{field}=")
      end
    end


    #
    # Removes annotation.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def remove!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}"
      end.execute!
    end

    #
    # added in release 1.6.0
    #
    # @example
    #   document = GroupDocs::Storage::Folder.list!.first.to_document
    #   annotation = GroupDocs::Document::Annotation.new(document: document)
    #   annotation.remove_annotations!
    #
    # Removes all annotations from document.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def remove_annotations!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/ant/{{client_id}}/files/#{document.file.guid}/annotations"
      end.execute!
        json[:delete_annotation_results]
    end

    #
    # Return an array of replies..
    #
    # @param [Hash] options
    # @option options [Time] :after
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Document::Annotation::Reply>]
    #
    # @raise [ArgumentError] If :after option is passed but it's not an instance of Time
    #
    def replies!(options = {}, access = {})
      Document::Annotation::Reply.get!(self, options, access)
    end

    #
    # Moves annotation to given coordinates.
    #
    # @param [Integer, Float] x
    # @param [Integer, Float] y
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def move!(x, y, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}/position"
        request[:request_body] = { :x => x, :y => y }
      end.execute!

      self.annotation_position = { :x => x, :y => y }
    end

    #
    # Changed in release 1.5.8
    #
    # Moves annotation marker to given coordinates.
    #
    # @param [GroupDocs::Annotation::Marker] marker Marker position
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def move_marker!(marker, access = {})
      marker.is_a?(GroupDocs::Document::Annotation::MarkerPosition) or raise ArgumentError,
        "Marker should be GroupDocs::Document::Annotation::MarkerPosition object, received: #{marker.inspect}"
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}/markerPosition"
        request[:request_body] = marker
      end.execute!

      if box && page_number
        box.x = marker.position[:x]
        box.y = marker.position[:y]
        page_number = marker.page
      else
        self.box = { :x => marker.position[:x], :y => marker.position[:y] }
        self.page_number = marker.page
      end
    end

    #
    # Sets access mode.
    #
    # @param [Symbol] mode
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def set_access!(mode, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}/annotationAccess"
        request[:request_body] = %w(public private).index(mode.to_s)
      end.execute!

      self.access = mode
    end

    #
    # Resize annotation.
    #
    # @param [Integer, Float] x
    # @param [Integer, Float] y
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def resize!(x, y, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}/size"
        request[:request_body] = { :width => x, :height => y }
      end.execute!
        self.box = { :width => x, :height => y }

    end

    #
    # Save Text Of Text Field.
    #
    # @param [String] fieldText
    # @param [String] fontFamily
    # @param [Integer, Float] fontSize
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def text_info!(fieldText, fontFamily, fontSize, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}/size"
        request[:request_body] = { :fieldText => fieldText, :fontFamily => fontFamily, :fontSize => fontSize }
      end.execute!

      self.fieldText = fieldText
      self.fontFamily = fontFamily
      self.fontSize = fontSize
    end

    #
    # Save Text Of Text Color.
    #
    # @param [Integer, Float] fontColor
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def text_color!(font_color, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/ant/{{client_id}}/annotations/#{guid}/size"
        request[:request_body] = { :fontColor => font_color }
      end.execute!

      self.fontColor = font_color
    end

  end # Document::Annotation
end # GroupDocs
