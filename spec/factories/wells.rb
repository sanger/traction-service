FactoryBot.define do
  factory :well do
    plate 
    position { 'A1' }

    factory :well_with_ont_samples do
      transient do
        samples { [{ name: 'Sample in A1' }] }
      end
  
      after :create do |well, options|
        options.samples.each do |sample_spec|
          sample = build(:sample, name: sample_spec[:name])
          sample.external_id = sample_spec[:external_id] if sample_spec.key?(:external_id)
          request = build(:request, sample: sample, requestable: nil )
          ont_request = create(:ont_request, request: request)
          create(:container_material, container: well, material: ont_request)
        end
      end
    end
  end
end
