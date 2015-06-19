## v.2.2.0

**Changes**
*`Storage::File.upload_google!` changed the required parameters
*`Storage.info!` added new parameters of response

**New**
*`Signature::Form#modify_form_field!` new method
* Added new attribute `Signature::Field` - "page", "locationX", "locationY", "locationWidth", "locationHeight", "forceNewField"


## v.2.1.0

**Changes**
*`Document.editor_fields!` return the all json
*`Document.update_changes!` the changes should be array
* Deleted attribute `Document::Annotation::Reviewer` - "full_name"


**New**
* Added new attributes `Document::Annotation::Reviewer` - "first_name", "last_name' 
* Added new `Document::Page`
* Added new attributes `Document::Change` - "type", "typeStr", "action', "actionStr"

## v.2.0.0

**Changes**
*`Signature::Form#fields!` renamed to `Signature::Form#get_fields!`
*`Signature::Form#get_fields!` the updates in request path
*`Document.self.metadata!` added 

**New**
* Added new attribute `Document` - "documentDescription"
* Added new attribute `Document::MetaData` - "type" and "url"
* Added new attribute `Document::Annotation` - "text"
* Added new attributes `Document::TemplateEditorFields` - "tableNumber" "tableRow" "tableColumn" "tableCell"

## v.1.9.0

**Changes**
* Deleted `Document#page_fixed_html!`
* Deleted `Document#page_html!`
* Deleted `Document#page_html_urls!`
* Deleted `Document#representations!`

**New**
* Added new attributes `User`
* Added new attribute `Signature::Envelope` - "lockDuringSign" 

## v1.8.1

**New**
* Added new attribute "email" to `Signature`

**Changes**
* `Document#sign_documents!` added new requere parameter for signer "email"

## v1.8.0
**New**

* Added `Document#add_questionnaire_template!`
* Added `Document#update_questionnaire_template!`
* Added `Document#delete_questionnaire_template!`
* Added `Signature::Form#get_participants!`

## v1.7.0

**Changes**

* `Document::Annotation` updated types of annotation
* `Document#templates!` added parameter<Hash> "settings"
* `Signature::Envelope#sign!` added parameter<Hash> "settings"
* `Signature::Form#sign!`  added parameter<Hash> settings and parameter<String> "filepath"
* `Signature::Form#fields!`  delete parameter "documentGuid"

**New**

* Added `Document#editor_fields!`
* Added `Document#questionnaire_template!`
* Added `Job.get_conversions!`
* Added new attributes `User`
* Added new attributes `DataSource::Field`
* Added new attributes `Document::Annotation`
* Added `Document::TemplateEditorFields`
* Added new attributes `Document::Field`
* Added `Document::TemplateEditorFieldStyle`
* Added `Questionnaire::Collector#decorate!`
* Added `Questionnaire::Collector#get_decorate!`
* Added `Questionnaire::QuestionnaireCollectorStyle`
* Added new attributes `Questionnaire::Question`
* Added new attributes `Signature::Envelope`
* Added `Signature::Form#update_partipicant!`
* Added `Signature::Form#validate_partipicant!`
* Added `Signature::Form#document_fields!`
* Added `Signature::Form#get_logs!`
* Added new attributes `Signature::Recipient`
* Added new attributes `Signature::Template`


## v1.6.0

**Changes**

* `Document::Annotation` updated types of annotation
* `Signature::FieldMethods#modify_field!` added parament "recipientGuid"

**New**

* Added `Documet::Annotation#remove_annotations!`
* Added `Document::Annotation` attributes
* Added `Document::Annotation::Reply` attributes
* Added `Document` attributes
* Added `Signature.public_get_default_email_template!`
* Added `Signature` template fields
* Added `Signature::Form` attribute
* Added `Signature::Envelope#resend!`

## v1.5.9

**Changes**

* `Api::Helpers::URL#sign_url` changes an initialize library OpenSSL 
* `Api::Helpers::AccessRights` changes an array ACCESS_RIGHTS 
* `Document#changes` updates in request path


## v1.5.8

**Changes**

* `Api::Helpers::REST#send_request!` new functionality for request type :DELETE
* `Document#access_mode_set!` updates in request path 
* `Document#details!` updates in request path
* `Document#compare!` updates in request path
* `Document#update_changes!` updates in request path
* `Document#changes` updates in request path
* `Document#download!` updates in request path. Fixed bugs
* `Signature#get_document_fields!` renamed to `Document#public_fields!`
* `Signature#sign_document!` renamed to `Document#public_sign_document!`
* `Document::Annotation.remove!` renamed to `Document::Annotation#remove!`
* Fixed bugs `Document::Annotation#move_marker!`
* Fixed bugs `Document::Annotation#resize!`
* Fixed bugs `Questionnaire#collectors!`
* Fixed bugs `Questionnaire#copy_to_templates!`
* Fixed bugs `Signature.verify!`
* Fixed bugs `Signature.sign_document_status!`
* `Signature::Envelope#add_recipient!` returns GroupDosc::Signature::Recipient
* `Signature#get_sign_envelope!` renamed to `Signature::Envelope#public_get!`
* `Signature#get_signed_documents!` renamed to `Signature::Envelope#public_signed_documents!  `
* `Signature#field_envelope_date!` renamed to `Signature::Envelope#date!`
* `Signature::Form#fields!` updated
* Fixed bugs `Signature::Form#assign_field!`
* `Subscription.self.list!` updated

**New**

* Added `Document#hyperlinks!`
* Added `Document::Annotation` attributes
* Added `Document::Annotation::MarkerPosition` class
* Added `Document::Annotation::Reply` attributes
* Added `Document::Field` attributes
* Added `Questionnaire` attributes
* Added `Questionnaire#get_document!`
* Added `Questionnaire.get_by_name!`
* Added `Questionnaire#delete_list!`
* Added `Questionnaire#delete_collectors_list!`
* Added `Questionnaire#delete_executions_list!`
* Added `Questionnaire#delete_datasources_list!`
* Added `Questionnaire::Collector#get_questionnaire!`
* Added `Questionnaire::Question` attributes
* Added `Questionnaire::Question::Conditions` class
* Added `Questionnaire::Question::Answer` attribute
* Added `Signature::Field` attributes
* Added `Signature::Field::Location` attributes
* Added `Storage::File#upload_cancel!`
* Added `User` attributes

## v1.5.3

**Changes**

* Fixes critical issue with unauthorized requests.

## v1.5.2

**Changes**

* Do not replace `{{client_id}}` if `:sign` is `false`.

## v1.5.1

**New**

* Added `:sign` flag `Api::Request.options` allowing request not to be signed

## v1.5.0

**New**

* Added `Signature.get_for_recipients!`
* Added `Signature#create_for_recipient!`
* Added `Signature#signature_data!`
* Added `Signature#initials_data!`

**Changes**

* `Signature::Envelope#fill_field!` supports `:public` flag
* `Signature::Envelope#sign!` supports `:public` flag
* `Signature::Form.get!` supports `:public` flag
* `Signature::Form#documents!` supports `:public` flag
* `Signature::Envelope#documents!` supports `:public` flag
* `Signature::Envelope#recipients!` supports `:public` flag

## v1.4.2

**New**

* Added new `Document` attributes

**Changes**

* Fixed `Signature` attributes
* Fixed `Document` access modes

## v1.4.1

**Changes**

* Fixed file guid lookup in `Form#documents!`
* URI now can handle `[]` corrrectly
* `Package#create!` now properly handles objects in sub-directories

## v1.4

**New**

* Added watermark support to `Signature::EntityFields` and `Signature::Form`
* Added signature and initials data support to `Signature`
* Added `Signature::Envelope#is_demo`
* Added `:scheduled` status for `Envelope`
* Added `Envelope#delegate_recipient!`
* Added `Envelope#signed_document!`
* Added `Signature::FieldMethods#assign_field!` support in templates and envelopes
* Added `Signature::Contact#add_integration!`
* `Signature::Form` now supports document methods
* `Signature::Form` now supports field methods

**Changes**

* Fixed `#owner_should_sign` and `#ordered_signature` in `Signature::EntityFields` as API now return boolean values
* Fixed `Signature::Role#can*` methods as API now return boolean values
* `Signature::Field#acceptable_values` should properly handle arrays
* `Signature::Form#fields_in_final_file_name` should properly handle arrays
* `Signature::DocumentMethods#documents!` now find documents both by `:documentId` and `:id`
* `Signature::Form#create!` now can be created without template

## v1.3

**New**

* Added Ruby 1.8 support
* Added Ruby 2.0 support
* Added `Document#thumbnails!`

## v1.2

**New**

* Added `Annotation::Collector` class
* Added `Collector.get!`
* Added `Collector#add!`
* Added `Collector#update!`
* Added `Collector#remove!`
* Added `Collector#executions!`
* Added `Collector#add_execution!`
* Added `Collector#fill!`
* Added `Document.templates!`
* Added `Questionnaire#executions!`
* Added `Questionnaire#collectors!`
* Added `Questionnaire#metadata!`
* Added `Questionnaire#update_metadata!`
* Added `Questionnaire#fields!`
* Added `Execution.get!`
* Added `Execution#delete!`
* Added `Execution#fill!`
* Added `Document.sign_documents!`
* Added `Document#page_images!`
* Added MIME helper

**Changes**

* Fixed `Questionnaire#create!`
* Fixed `Field#rectangle=`
* Fixed `File#download!`
* Fixed `Folder#list!` params handling (see issue #30)
* Fixed coordinates-related responses (they now have downcased fields)
* Fixed `Job#add_datasource!`
* `Questionnaire.all!` now accepts optional paging and status filter params
* New attributes for a lot of entities

**Removed**

* Removed `Questionnaire#create_execution!`


## v1.1

**New**

* Added `Annotation::Reviewer` class
* Added `Reviewer.all!`
* Added `Reviewer.set!`
* Added `Job#delete!`
* Added `Document#shared_link_access_rights!`
* Added `Document#set_shared_link_access_rights!`
* Added `Document#set_reviewers!`
* Added `Document#add_collaborotor!`
* More attributes for `User` class
* Added `Annotation#move_marker!`
* Added new `Job` action - `:compare`

**Changes**

* Moved `Annotation#collaborators!` and `Annotation#set_collaborators!` to `Document` class as it makes more sense
* `Document#set_collaborators!` now accepts options `version` parameter (default to `1`)


## v1.0

**New**

* Added fully-featured Signature API
* Added API to retrieve subscription plans
* Added `Annotation#set_access!` to control annotation access: public or private
* Added `Job.get!` to retrieve job by its identifier
* Added `Job#delete_document!`
* Added `File.upload_web!` to convert webpages to documents
* Added `File#move_to_trash!`
* Added `User.users!` to retrieve my account's users

**Changes**

* `File` and `Folder` has changed the way paths are handled. Path should no longer start with `/`
* `File.upload!` now accept hash of options as argument: `:path` to upload to, `:name` to rename file, `:description` to add description to file
* `File#move!` now accept hash of options as argument: `:name` to rename file
* `File#copy!` now accept hash of options as argument: `:name` to rename file

**Removed**

* `Document.all!` is removed (slow recursive implementation)
* `Document.find!` is removed (slow recursive implementation)
* `Document.find_all!` is removed (slow recursive implementation)
* `File.all!` is removed (slow recursive implementation)
* `File.find!` is removed (slow recursive implementation)
* `File.find_all!` is removed (slow recursive implementation)
* `Folder.all!` is removed (slow recursive implementation)
* `Folder.find!` is removed (slow recursive implementation)
* `Folder.find_all!` is removed (slow recursive implementation)
* `Extensions::LookUp` is removed (slow recursive implementation)
* `File#upload!` is removed (not really needed, use `File.upload!`)
* `Folder#rename!` is removed (has some quirks due to API, use `Folder#move!` instead)

## v0.3.11

* Fix for critical bug in `Entity#to_hash`

## v0.3.10

* Updated `Document#metadata!`
* Fixed `Folder#move!`
* Fixed `Folder#copy!`

## v0.3.9

* Added `File#upload!`
* Proper handling of `File#file_type`
* More annotation types
* `Document#datasource!` options are now optional

## v0.3.8

* Updated `Datasource for new API
* Updated `Datasource::Field` for new API
* Some minor fixes

## v0.3.7

* More flexible `Execution#owner=` and specs for it
* More flexible `Execution#executive=` and specs for it
* More flexible `Execution#approver=` and specs for it

## v0.3.6

* `Questionnaire::Execution` now returns objects for`owner`, `executive` and `approver`

## v0.3.5

* Methods to retrieve and update user profile information

## v0.3

**This release breaks backwards compatibility**

New API version uses strings for job actions, access modes, statuses, file types, etc. This release reflects corresponding changes.

## v0.2.11

* Added `Questionnaire#default_answer` and `Questionnaire#default_answer=`

## v0.2.10

* Added `Annotation#collaborators!`

## v0.2.9

* Added `Annotation#position`
* Added `Annotation#move!`

## v0.2.8

* Human-readable `Annotation#access`
* Machine-readable `Annotation#access=`
* `Document#annotations!` now handles `null` in "annotations" response

## v0.2.7

* `Job#documents!` now updates job status

## v0.2.6

* Minor `Job` and `Document` fixes

## v0.2.5

* `Document` now parses `outputs` to `Storage::File` object
* `Document` now has `output_formats` with corresponding parser
* `Document#convert!` URI was changed
* Job API methods were returning job documents in different format

## v0.2.4

* `Job` has now more attributes
* `Job#documents=` should not raise error when `nil` is passed
* Timestamps are being returned in milliseconds, while we were parsing them as seconds

## v0.2.3

* Fixed `Entity#variable_to_accessor` bugs
* Updated `Document#fields!` to always include geometry
* Added more accessors to `Rectange` (fixes `#inspect` issues)

## v0.2.2

* Updated `Folder.list!` for response changes

## v0.2.1

* `Sugar` namespace is now `Extensions`
* Removed `File#delete!` workaround

## v0.2

* `File#compress!` supports only zip, so parameter was removed
* `Errors` namespace was removed
* `BadRequestError` now shows only error message
* `File#upload!` no longer uses description, so parameter was removed
* Added `File#file_type`
* Added `File::DOCUMENT_TYPES`. `File#type` now returns document type in human-readable format
* `Folder#list!` capitalizes `:order_by` option
* Introduced `URLHelper#normalize_path`. Path is now normalized before sending request.
* HTTP methods as strings are now allowed
* Workaround for `File#delete!`
* Updated gems

## v0.1

Initial release
