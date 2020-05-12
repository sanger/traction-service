FactoryBot.define do
  factory :well do
    plate 
    position { 'A1' }

    factory :well_with_ont_requests do
      transient do
        requests { [{ name: 'Sample in A1', external_id: 'test external id' }] }
      end
  
      after :create do |well, options|
        options.requests.each do |request_spec|
          ont_request = create(:ont_request, name: request_spec[:name], external_id: request_spec[:external_id])
          create(:container_material, container: well, material: ont_request)
        end
      end
    end

    factory :well_with_tagged_ont_requests do
      transient do
        requests { [{ name: 'Sample in well', external_id: 'test external id' }] }
      end
  
      after :create do |well, options|
        options.requests.each do |request_spec|
          ont_request = create(:ont_request_with_tags, tags_count: 1, name: request_spec[:name], external_id: request_spec[:external_id])
          create(:container_material, container: well, material: ont_request)
        end
      end
    end
  end
end
