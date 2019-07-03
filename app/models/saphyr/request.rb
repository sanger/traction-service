module Saphyr
  class Request < ApplicationRecord

    include Material

    validates :external_study_id, presence: true

    belongs_to :sample, optional: true
    belongs_to :request, polymorphic: true, optional: true
    has_one :request, class_name: '::Request', as: :requestable

    # validates_associated :sample
  end
end