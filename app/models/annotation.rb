# frozen_string_literal: true

# Annotation represents a user-supplied comment or note attached to any annotatable resource.
#
# == Schema Information
#
# Table name: annotations
#
#  id                 :bigint           not null, primary key
#  annotation_type_id :bigint           not null, foreign key
#  annotatable_type   :string           not null
#  annotatable_id     :bigint           not null
#  comment            :string(500)      not null
#  user               :string(10)       not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# == Associations
#
# * +annotation_type+ - The type/category of the annotation.
# * +annotatable+     - The resource (polymorphic) this annotation is attached to.
#
# == Validations
#
# * +comment+ - Must be present and at most 500 characters.
# * +user+    - Must be present and at most 10 characters.
#
class Annotation < ApplicationRecord
  belongs_to :annotation_type
  belongs_to :annotatable, polymorphic: true

  validates :comment, presence: true, length: { maximum: 500 }
  validates :user, presence: true, length: { maximum: 10 }
end
