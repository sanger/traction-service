FactoryBot.define do
  factory :well do
    plate 
    position { 'A1' }

    factory :well_with_ont_requests do
      transient do
        requests { [{ name: 'Sample in A1' }] }
      end
  
      after :create do |well, options|
        options.requests.each do |request_spec|
          ont_request = build(:ont_request, name: request_spec[:name])
          ont_request.external_id = request_spec[:external_id] if request_spec.key?(:external_id)
          create(:container_material, container: well, material: ont_request)
        end
      end
    end
  end
end
