module GroupDocs
  module Storage
    class Package < GroupDocs::Api::Entity

      # @attr [String] name Package name
      attr_accessor :name
      # @attr [Array] objects Storage entities to be packed
      attr_accessor :objects

      #
      # Appends object to be packed.
      #
      # @param [GroupDocs::Storage::File, GroupDocs::Storage::Folder] object
      #
      def <<(object)
        @objects ||= Array.new
        @objects << object
      end

      #
      # Creates package on server.
      #
      # @param [Hash] access Access credentials
      # @options access [String] :client_id
      # @options access [String] :private_key
      # @return [String] URL of package for downloading
      #
      def create!(access = {})
        json = GroupDocs::Api::Request.new do |request|
          request[:access] = access
          request[:method] = :POST
          request[:path] = "/storage/{{client_id}}/packages/#{name}.zip"
          request[:request_body] = @objects.map(&:name)
        end.execute!

        json[:result][:url]
      end

    end # Package
  end # Storage
end # GroupDocs
