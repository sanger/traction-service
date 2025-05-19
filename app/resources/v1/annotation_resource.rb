# frozen_string_literal: true

module V1
  # Provides a JSON:API resource of {Annotation} model.
  #
  # AnnotationResource represents a user-supplied comment or note attached to
  # any annotatable resource.
  # It allows creation of annotations, but updates and deletions are not permitted via the API.
  #
  ## Primary relationships:
  #
  # * annotation_type {V1::AnnotationTypeResource} - The type/category of the annotation.
  #
  # @example
  #
  #   curl -X GET http://localhost:3000/v1/annotations/1
  #   curl -X GET http://localhost:3000/v1/annotations/
  #
  #   curl -X POST "http://yourdomain.com/v1/annotations" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "annotations",
  #         "attributes": {
  #           "comment": "This is a note",
  #           "user": "jsmith",
  #           "annotation_type_id": 1,
  #           "annotatable_type": "Pacbio::Run",
  #           "annotatable_id": 1
  #         },
  #       }
  #     }'
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

    # Prevent updates and deletes through the API
    def replace_fields(_fields)
      raise JSONAPI::Exceptions::RecordLocked, 'Annotations cannot be updated'
    end

    def remove
      raise JSONAPI::Exceptions::RecordLocked, 'Annotations cannot be deleted'
    end
  end
end
