module Saphyr
  class Request < ApplicationRecord

    include Material

    validates :external_study_id, presence: true

    belongs_to :sample

    validates_associated :sample
  end
end