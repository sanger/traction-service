FactoryBot.define do
  factory :plate_with_ont_samples, class: Plate do
    transient do
      samples { [{ position: 'A1', name: 'Sample in A1' }] }
    end

    after :create do |plate, options|
      options.samples.each do |sample_spec|
        sample = create(:sample, name: sample_spec[:name])
        request = create(:request, sample: sample)
        ont_request = create(:ont_request, request: request)
        well = create(:well, plate: plate, position: sample_spec[:position])
        create(:container_material, container: well, material: ont_request)
      end
    end
  end
end
