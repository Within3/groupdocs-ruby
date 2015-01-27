# added in release 1.5.8
module GroupDocs
  class Document::Annotation::MarkerPosition< Api::Entity

    #
    # example
    # marker = GroupDocs::Document::Annotation::MarkerPosition.new()
    # marker.position = {:x => 100, :y => 100}
    # marker.page = 1

    # @attr [Array](x,y) position
    attr_accessor :position

    # @attr [Int] page
    attr_accessor :page

  end
end