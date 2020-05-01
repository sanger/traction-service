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
          sample = create(:sample, name: sample_spec[:name])
          request = build(:request, sample: sample, requestable: nil )
          ont_request = create(:ont_request, request: request)
          create(:container_material, container: well, material: ont_request)
        end
      end
    end
  end
end
