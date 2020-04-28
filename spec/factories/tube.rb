FactoryBot.define do
  factory :tube do
    factory :tube_with_saphyr_request do
      after :create do |tube|
        tube.container_material = create(:container_material,
                                          container: tube,
                                          material: create(:saphyr_request))
      end
    end

    factory :tube_with_saphyr_library do
      after :create do |tube|
        tube.container_material = create(:container_material,
                                          container: tube,
                                          material: create(:saphyr_library))
      end
    end

    factory :tube_with_pacbio_library do
      after :create do |tube|
        tube.container_material = create(:container_material,
                                          container: tube,
                                          material: create(:pacbio_library))
      end
    end

    factory :tube_with_pacbio_request do
      after :create do |tube|
        tube.container_material = create(:container_material,
                                          container: tube,
                                          material: create(:pacbio_request))
      end
    end
  end

end
