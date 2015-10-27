module GroupDocs
  class User < Api::Entity

    include Api::Helpers::AccessRights

    #
    # Returns current user profile.
    #
    # @example
    #   user = GroupDocs::User.get!
    #   user.first_name
    #   #=> "John"
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::User]
    #
    def self.get!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/mgmt/{{client_id}}/profile'
      end.execute!

      new(json[:user])
    end

    #
    # Updates user account if it's created, otherwise creates new.
    #
    # @example
    #   user = GroupDocs::User.new
    #   user.primary_email = 'john@smith.com'
    #   user.nickname = 'johnsmith'
    #   user.first_name = 'John'
    #   user.last_name = 'Smith'
    #   # make sure to save user as it has updated attributes
    #   user = GroupDocs::User.update_account!(user)
    #
    # @param [GroupDocs::User] user
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::User]
    #
    def self.update_account!(user, access = {})
      user.is_a?(GroupDocs::User) or raise ArgumentError,
        "User should be GroupDocs::User object, received: #{user.inspect}"

      data = user.to_hash

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/mgmt/{{client_id}}/account/users/#{user.nickname}"
        request[:request_body] = data
      end.execute!

      GroupDocs::User.new data.merge(json)
    end

    #
    # Delete account user.
    #
    # @example
    #   user = GroupDocs::User.get!
    #   GroupDocs::User.delete!(user.users!.last)
    #   #=> "826e3b54e009ce51"
    #
    # @param [GroupDocs::User] user
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    # @raise [ArgumentError] if user is not GroupDocs::User object
    #
    def self.delete!(user, access = {})
      user.is_a?(GroupDocs::User) or raise ArgumentError,
        "User should be GroupDocs::User object, received: #{user.inspect}"

      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/mgmt/{{client_id}}/account/users/#{user.primary_email}"
      end.execute!

      json[:guid]
    end

    #
    # Generates new user embed key.
    #
    # @example
    #   GroupDocs::User.generate_embed_key!('test-area')
    #   #=> "60a06ef8f23a49cf807977f1444fbdd8"
    #
    # @param [String] area
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.generate_embed_key!(area, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/{{client_id}}/embedkey/new/#{area}"
      end.execute!

      json[:key][:guid]
    end

    #
    # Get user embed key. Generate new embed key if area not exists.
    #
    # @example
    #   GroupDocs::User.get_embed_key!('test-area')
    #   #=> "60a06ef8f23a49cf807977f1444fbdd8"
    #
    # @param [String] area
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.get_embed_key!(area, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/{{client_id}}/embedkey/#{area}"
      end.execute!

      json[:key][:guid]
    end

    #
    # Get area name by embed key.
    #
    # @example
    #   GroupDocs::User.area!('60a06eg8f23a49cf807977f1444fbdd8')
    #   #=> "test-area"
    #
    # @param [String] embed_key
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.area!(embed_key, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/{{client_id}}/embedkey/guid/#{embed_key}"
      end.execute!

      json[:key][:area]
    end

    #
    # Returns an array of storage providers.
    #
    # @example
    #   providers = GroupDocs::User.providers!
    #   providers.first.provider
    #   #=> "Dropbox"
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::Storage::Provider>]
    #
    def self.providers!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/mgmt/{{client_id}}/storages'
      end.execute!

      json[:providers].map do |provider|
        Storage::Provider.new(provider)
      end
    end

    #
    # Adds a new storage provider configuration.
    #
    # @param [String] provider Storage provider name
    # @param [Hash] access Access credentials
    # @param [Array] provider_info
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def add_provider!(provider, provider_info = {}, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/mgmt/{{client_id}}/storages/#{provider}"
        request[:request_body] = provider_info
      end.execute!

    end

    #
    # Updates user's storage provider configuration.
    #
    # @param [String] provider Storage provider name
    # @param [Hash] access Access credentials
    # @param [Array] provider_info
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def update_provider!(provider, provider_info = {}, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/mgmt/{{client_id}}/storages/#{provider}"
        request[:request_body] = provider_info
      end.execute!

    end


    #
    # Revoke.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def self.revoke!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/mgmt/{{client_id}}/revoke"
      end.execute!

    end
    #
    # Logins user using user name and password.
    #
    # @example
    #   user = GroupDocs::User.login!('doe@john.com', 'password')
    #   user.first_name
    #   #=> "John"
    #
    # @return [GroupDocs::User]
    #
    def self.login!(email, password)
      json = Api::Request.new do |request|
        request[:sign] = false
        request[:method] = :POST
        request[:path] = "/shared/users/#{email}/logins"
        request[:request_body] = password
      end.execute!

      new(json[:user])
    end

    #
    # Logins user using user name and password.
    #
    # @param [String]guid
    # @param [Hash] options
    # @option [String] :filename File name
    # @option [Boolean] :render Render
    #
    def self.download!(path, name, guid, options = {})
      api = Api::Request.new do |request|
        request[:sign] = false
        request[:method] = :DOWNLOAD
        request[:path] = "/shared/files/#{guid}"
      end
      api.add_params(options)
      response = api.execute!

      filepath = "#{path}/#{name}"
      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

    #
    # Get file in xml.
    #
    #@param [String] guid
    #
    def self.get_xml!(path, name, guid)
      response = Api::Request.new do |request|
        request[:sign] = false
        request[:method] = :DOWNLOAD
        request[:path] = "/shared/files/#{guid}/xml"
      end.execute!

      filepath = "#{path}/#{name}"
      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

    #
    # Get file in html.
    #
    #@param [String] guid
    #
    def self.get_html!(path, name, guid)
      response = Api::Request.new do |request|
        request[:sign] = false
        request[:method] = :DOWNLOAD
        request[:path] = "/shared/files/#{guid}/html"
      end.execute!

      filepath = "#{path}/#{name}"
      Object::File.open(filepath, 'wb') do |file|
        file.write(response)
      end

      filepath
    end

    #
    # Get file in html.
    #
    #@param [String] path
    #
    def get_packages!(path)
      response = Api::Request.new do |request|
        request[:sign] = false
        request[:method] = :GET
        request[:path] = "/shared/packages/#{path}"
      end.execute!

      Object::File.open(path, 'wb') do |file|
        file.write(response)
      end

      path
    end

    # @attr [Integer] id
    attr_accessor :id
    # @attr [String] guid
    attr_accessor :guid
    # @attr [String] nickname
    attr_accessor :nickname
    # @attr [String] firstname
    attr_accessor :firstname
    # @attr [String] lastname
    attr_accessor :lastname
    # @attr [String] primary_email
    attr_accessor :primary_email
    # @attr [String] private_key
    attr_accessor :private_key
    # @attr [String] password_salt
    attr_accessor :password_salt
    # @attr [Integer] claimed_id
    attr_accessor :claimed_id
    # @attr [String] token
    attr_accessor :token
    # @attr [String] storage
    attr_accessor :storage
    # @attr [String] photo
    attr_accessor :photo
    # @attr [Boolean] active
    attr_accessor :active
    # @attr [Boolean] news_enabled
    attr_accessor :news_enabled
    # @attr [Time] signed_up_on
    attr_accessor :signed_up_on
    # @attr [Integer] color
    attr_accessor :color
    # @attr [String] customEmailMessage
    attr_accessor :customEmailMessage
    # @attr [Array] roles
    attr_accessor :roles

    # added in release 1.5.8
    # @attr [List] avatar
    attr_accessor :avatar

    # added in release 1.7.0
    # @attr [Boolean] trial
    attr_accessor :trial
    # @attr [Boolean] news_eanbled
    attr_accessor :news_eanbled
    # @attr [Boolean] alerts_eanbled
    attr_accessor :alerts_eanbled
    # @attr [Boolean] support_eanbled
    attr_accessor :support_eanbled
    # @attr [Boolean] support_email
    attr_accessor :support_email
    # @attr [String] apps
    attr_accessor :apps
    # @attr [Boolean] annotation_branded
    attr_accessor :annotation_branded
    # @attr [Boolean] viewer_branded
    attr_accessor :viewer_branded
    # @attr [Boolean] is_real_time_broadcast_enabled
    attr_accessor :is_real_time_broadcast_enabled
    # @attr [Boolean] is_scroll_broadcast_enabled
    attr_accessor :is_scroll_broadcast_enabled
    # @attr [Boolean] is_zoom_broadcast_enabled
    attr_accessor :is_zoom_broadcast_enabled
    # @attr [List] annotation_logo
    attr_accessor :annotation_logo
    # @attr [List] pointer_tool_cursor
    attr_accessor :pointer_tool_cursor
    # @attr [Integer] annotation_header_options
    attr_accessor :annotation_header_options
    # @attr [Boolean] is_annotation_navigation_widget_enabled
    attr_accessor :is_annotation_navigation_widget_enabled
    # @attr [Boolean] is_annotation_zoom_widget_enabled
    attr_accessor :is_annotation_zoom_widget_enabled
    # @attr [Boolean] is_annotation_download_widget_enabled
    attr_accessor :is_annotation_download_widget_enabled
    # @attr [Boolean] is_annotation_print_widget_enabled
    attr_accessor :is_annotation_print_widget_enabled
    # @attr [Boolean] is_annotation_help_widget_enabled
    attr_accessor :is_annotation_help_widget_enabled
    # @attr [Boolean] is_right_panel_enabled
    attr_accessor :is_right_panel_enabled
    # @attr [Boolean] is_thumbnails_panel_enabled
    attr_accessor :is_thumbnails_panel_enabled
    # @attr [Boolean] is_standard_header_always_shown
    attr_accessor :is_standard_header_always_shown
    # @attr [Boolean] is_toolbar_enabled
    attr_accessor :is_toolbar_enabled
    # @attr [Boolean] is_text_annotation_button_enabled
    attr_accessor :is_text_annotation_button_enabled
    # @attr [Boolean] is_rectangle_annotation_button_enabled
    attr_accessor :is_rectangle_annotation_button_enabled
    # @attr [Boolean] is_point_annotation_button_enabled
    attr_accessor :is_point_annotation_button_enabled
    # @attr [Boolean] is_strikeout_annotation_button_enabled
    attr_accessor :is_strikeout_annotation_button_enabled
    # @attr [Boolean] is_polyline_annotation_button_enabled
    attr_accessor :is_polyline_annotation_button_enabled
    # @attr [Boolean] is_typewriter_annotation_button_enabled
    attr_accessor :is_typewriter_annotation_button_enabled
    # @attr [Boolean] is_watermark_annotation_button_enabled
    attr_accessor :is_watermark_annotation_button_enabled
    # @attr [Boolean] is_annotation_document_name_shown
    attr_accessor :is_annotation_document_name_shown
    # @attr [List] annotation_navigation_icons
    attr_accessor :annotation_navigation_icons
    # @attr [List] annotation_tool_icons
    attr_accessor :annotation_tool_icons
    # @attr [Integer] annotation_background_color
    attr_accessor :annotation_background_color
    # @attr [Integer] viewer_logo
    attr_accessor :viewer_logo
    # @attr [Integer] viewer_options
    attr_accessor :viewer_options
    # @attr [Boolean] is_viewer_navigation_widget_enabled
    attr_accessor :is_viewer_navigation_widget_enabled
    # @attr [Boolean] is_viewer_zoom_widget_enabled
    attr_accessor :is_viewer_zoom_widget_enabled
    # @attr [Boolean] is_viewer_download_widget_enabled
    attr_accessor :is_viewer_download_widget_enabled
    # @attr [Boolean] is_viewer_print_widget_enabled
    attr_accessor :is_viewer_print_widget_enabled
    # @attr [Boolean] is_viewer_help_widget_enabled
    attr_accessor :is_viewer_help_widget_enabled
    # @attr [Boolean] is_viewer_document_name_shown
    attr_accessor :is_viewer_document_name_shown
    # @attr [Boolean] isviewer_right_mouse_button_menu_enabled
    attr_accessor :isviewer_right_mouse_button_menu_enabled
    # @attr [Time] signedinOn
    attr_accessor :signedinOn
    # @attr [Integer] signin_count
    attr_accessor :signin_count
    # @attr [Boolean] signature_watermark_enabled
    attr_accessor :signature_watermark_enabled
    # @attr [Boolean] signature_desktop_notifications
    attr_accessor :signature_desktop_notifications
    # @attr [Integer] webhook_notification_retries
    attr_accessor :webhook_notification_retries
    # @attr [String] webhook_notification_failed_recipients
    attr_accessor :webhook_notification_failed_recipients
    # @attr [String] signature_color
    attr_accessor :signature_color
    # @attr [Boolean] signature_save_field_changes_automatically
    attr_accessor :signature_save_field_changes_automatically
    # @attr [Boolean] signature_use_custom_email_templates
    attr_accessor :signature_use_custom_email_templates
    # @attr [String] signature_envelope_sent_owner_template
    attr_accessor :signature_envelope_sent_owner_template
    # @attr [String] signature_envelope_sent_other_template
    attr_accessor :signature_envelope_sent_other_template
    # @attr [String] signature_envelope_completed_template
    attr_accessor :signature_envelope_completed_template
    # @attr [String] signature_envelope_signed_template
    attr_accessor :signature_envelope_signed_template
    # @attr [String] signature_envelope_declined_template
    attr_accessor :signature_envelope_declined_template
    # @attr [String] signature_envelope_failed_template
    attr_accessor :signature_envelope_failed_template
    # @attr [String] signature_envelope_cancelled_template
    attr_accessor :signature_envelope_cancelled_template
    # @attr [String] signature_envelope_expired_template
    attr_accessor :signature_envelope_expired_template
    # @attr [String] signature_envelope_step_expired_template
    attr_accessor :signature_envelope_step_expired_template
    # @attr [String] signature_envelope_recipient_reminder_template
    attr_accessor :signature_envelope_recipient_reminder_template
    # @attr [String] signature_form_signed_template
    attr_accessor :signature_form_signed_template
    # @attr [Boolean] signature_form_require_user_auth_for_sign
    attr_accessor :signature_form_require_user_auth_for_sign
    # @attr [Boolean] signature_form_request_user_auth_by_photo
    attr_accessor :signature_form_request_user_auth_by_photo
    # @attr [Boolean] signature_form_require_user_identity_validation
    attr_accessor :signature_form_require_user_identity_validation
    # @attr [Boolean] signature_envelope_require_user_auth_for_sign
    attr_accessor :signature_envelope_require_user_auth_for_sign
    # @attr [Boolean] signature_envelope_request_user_auth_by_photo
    attr_accessor :signature_envelope_request_user_auth_by_photo
    # @attr [Boolean] signature_enable_uploaded_signature
    attr_accessor :signature_enable_uploaded_signature
    # @attr [Boolean] signature_enable_typed_signature
    attr_accessor :signature_enable_typed_signature
    # @attr [Boolean] signature_enable_envelope_comment
    attr_accessor :signature_enable_envelope_comment
    # @attr [Boolean] signature_enable_form_comment
    attr_accessor :signature_enable_form_comment

    # added in release 1.9.0
    # @attr [Boolean] is_text_replacement_annotation_button_enabled
    attr_accessor :is_text_replacement_annotation_button_enabled
    # @attr [Boolean] is_arrow_annotation_button_enabled
    attr_accessor :is_arrow_annotation_button_enabled
    # @attr [Boolean] is_text_redaction_annotation_button_enabled
    attr_accessor :is_text_redaction_annotation_button_enabled
    # @attr [Boolean] is_resource_redaction_annotation_button_enabled
    attr_accessor :is_resource_redaction_annotation_button_enabled
    # @attr [Boolean] is_text_underline_annotation_button_enabled
    attr_accessor :is_text_underline_annotation_button_enabled
    # @attr [Boolean] is_distance_annotation_button_enabled
    attr_accessor :is_distance_annotation_button_enabled

    # added in release 2.3.0
    # @attr [Boolean]  is_viewer_search_widget_enabled
    attr_accessor :is_viewer_search_widget_enabled

    # Human-readable accessors
    alias_accessor :first_name,           :firstname
    alias_accessor :last_name,            :lastname
    alias_accessor :custom_email_message, :customEmailMessage


    #
    # Converts access rights to human-readable format flag.
    # @return [Array<Symbol>]
    #
    def access_rights
      convert_byte_to_access_rights @access_rights if @access_rights
    end

    #
    # Converts access rights to machine-readable format flag.
    # @param [Array<Symbol>] rights
    #
    def access_rights=(rights)
      if rights.is_a?(Array)
        rights = convert_access_rights_to_byte(rights)
      end
      @access_rights = rights
    end

    #
    # Converts timestamp which is return by API server to Time object.
    #
    # @return [Time]
    #
    def signed_up_on
      Time.at(@signed_up_on / 1000)
    end

    # Compatibility with response JSON
    alias_method :pkey=,       :private_key=
    alias_method :pswd_salt=,  :password_salt=
    alias_method :signedupOn=, :signed_up_on=

    #
    # Updates user profile.
    #
    # @example
    #   user = GroupDocs::User.get!
    #   user.first_name = 'John'
    #   user.last_name = 'Smith'
    #   user.update!
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def update!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = '/mgmt/{{client_id}}/profile'
        request[:request_body] = to_hash
      end.execute!
    end

    #
    # Updates user profile.
    #
    # @example
    #   user = GroupDocs::User.get!
    #   old_password = user.password_salt
    #   new_password = 'Smith'
    #   user.update_password!
    # @param [Array] pas_info ([old_password, new_password, reset_token])
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def self.update_password!(pas_info = {}, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = '/mgmt/{{client_id}}/profile/password'
        request[:request_body] = pas_info
      end.execute!
    end

    #
    # Get user profile by reset token
    #
    # @param [String] callerId
    # @param [Array] options
    # @option [Hash] :token
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.reset_token!(caller_id, options ={}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/#{caller_id}/reset-tokens"
      end
      api.add_params(options)
      api.execute!

    end

    #
    # Get user profile by reset token
    #
    # @param [String] callerId
    # @param [Array] options
    # @option [Hash] :token
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.verif_token!(caller_id, options ={}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/#{caller_id}/verif-tokens"
      end
      api.add_params(options)
      api.execute!

    end

    #
    # Get user profile by verif token
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array<GroupDocs::User>]
    #
    def users!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/mgmt/{{client_id}}/account/users'
      end.execute!

      json[:users].map do |user|
        GroupDocs::User.new(user)
      end
    end

    #
    # Get user profile by claimed token
    #
    # @param [String] callerId
    # @param [Array] options
    # @option [Hash] :token
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.claimed_token!(caller_id, options ={}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/#{caller_id}/claimed-tokens"
      end
      api.add_params(options)
      api.execute!

    end

    #
    # Get alien user profile
    #
    # @param [String] callerId
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.get_profile!(caller_id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/#{caller_id}/user/{{client_id}}/profile"
      end.execute!

      json[:user]
    end

    #
    # Update alien user profile
    #
    # @param [String] callerId
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def update_profile!(caller_id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/mgmt/#{caller_id}/user/{{client_id}}/profile"
        request[:request_body] = to_hash
      end.execute!

      json[:user_guid]
    end

    #
    # Create new user
    #
    # @param [String] callerId
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::User]
    #
    def create_user!(caller_id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/mgmt/#{caller_id}/user"
        request[:request_body] = to_hash
      end.execute!

    end

    #
    # Create new login
    #
    # @param [String] callerId
    # @param [Hash] options
    # @option options [String] :password
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [GroupDocs::User]
    #
    def self.create_login!(caller_id, options = {}, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :POST
        request[:path] = "/mgmt/#{caller_id}/user/{{client_id}}/logins"
      end
      api.add_params(options)
      api.execute!

    end

    #
    # Change alien user password.
    #
    # @example
    #   user = GroupDocs::User.get!
    #   old_password = user.password_salt
    #   new_password = 'Smith'
    #   user.update_password!
    #
    # @param [String] callerId
    # @param [Array] pas_info ([old_password, new_password, reset_token])
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def self.update_alien_password!(caller_id, pas_info = {}, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :PUT
        request[:path] = "/mgmt/#{caller_id}/users/{{client_id}}password"
        request[:request_body] = pas_info
      end.execute!

      json[:user_guid]
    end

    #
    # Change alien user password.
    #
    # @param [String] callerId
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    #
    def self.reset_alien_password!(caller_id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/mgmt/#{caller_id}/users/{{client_id}}password"
      end.execute!

      json[:user_name]
    end

    #
    # Returns an array of roles.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def roles!(access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = '/mgmt/{{client_id}}/roles'
      end.execute!

      json[:roles]
    end

    #
    # Returns an array of roles.
    #
    # # @param [String] callerId
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.user_roles!(caller_id, access = {})
      json = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/#{caller_id}/users/{{client_id}}/roles"
      end.execute!

      json[:roles]
    end

    #
    # Set user roles.
    #
    # @param [String] callerId
    # @param [Hash] role_info (:id, :name)
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.set_user_roles!(caller_id, role_info = {}, access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/#{caller_id}/users/{{client_id}}/roles"
        request[:request_body] = role_info
      end.execute!

    end

    #
    # Returns an account information
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [Array]
    #
    def self.get_account!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :GET
        request[:path] = "/mgmt/{{client_id}}/account"
      end.execute!
    end

    #
    # Remove account user.
    #
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.remove_account!(access = {})
      Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/mgmt/{{client_id}}/account"
      end.execute!
    end


    # added in release 2.3.0
    #
    # Remove account by request.
    #
    # @param [String] email User email
    # @param [String] nonce Removal nonce
    # @param [Hash] access Access credentials
    # @option access [String] :client_id
    # @option access [String] :private_key
    # @return [String]
    #
    def self.delete_account!(email, nonce, access = {})
      api = Api::Request.new do |request|
        request[:access] = access
        request[:method] = :DELETE
        request[:path] = "/mgmt/{{client_id}}/account/users/removeaccount/#{email}"
      end
      api.add_params(nonce)
      api.execute!
    end

  end # User
end # GroupDocs
