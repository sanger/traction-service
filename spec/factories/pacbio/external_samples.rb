# ExternalSamples
class ExternalSample

  def initialize(attributes = {})

    @attributes = attributes

    attributes.each do |k, v|
      self.class.send(:define_method, k, proc { v })
    end
  end

  def to_h
    @attributes
  end
  
end

FactoryBot.define do
  factory :external_sample, class: ExternalSample do

    sequence(:name) { |n| "Sample#{n}" }
    sequence(:external_id, &:to_s)
    species { 'human' }
    library_type { 'library_type_1' }
    estimate_of_gb_required { 100 }
    number_of_smrt_cells { 3 }
    cost_code { 'PSD1234' }
    external_study_id { '1' }

    initialize_with { new(**attributes).to_h }

    skip_create

  end
end