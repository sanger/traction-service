# frozen_string_literal: true

module V1
  # Provides a JSON:API resource of {Annotation}.
  #
  # @note This endpoint can't be directly accessed via the `/v1/annotations/` endpoint
  # as it is not currently used.
  #
  class AnnotationResource < JSONAPI::Resource
    model_name 'Annotation'

    # @!attribute [rw] comment
    #   @return [String] the annotation text (required, max 500 chars)
    # @!attribute [rw] user
    #   @return [String] the user who created the annotation (required, max 10 chars)
    # @!attribute [rw] created_at
    #   @return [DateTime] the timestamp when the annotation was created
    # @!attribute [rw] annotation_type_id
    #   @return [Integer] the ID of the annotation type
    # @!attribute [rw] annotatable_type
    #   @return [String] the type of the resource this annotation is attached to
    # @!attribute [rw] annotatable_id
    #   @return [Integer] the ID of the resource this annotation is attached to

    attributes :comment, :user, :created_at, :annotation_type_id, :annotatable_type, :annotatable_id

    has_one :annotation_type

    def created_at
      @model.created_at.to_fs(:us)
    end

    # Prevent updates and deletes through the API
    def replace_fields(_fields)
      raise JSONAPI::Exceptions::RecordLocked, 'Annotations cannot be updated'
    end

    def remove
      raise JSONAPI::Exceptions::RecordLocked, 'Annotations cannot be deleted'
    end
  end
end
