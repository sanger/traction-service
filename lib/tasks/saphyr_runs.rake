# frozen_string_literal: true

require 'securerandom'

namespace :saphyr_runs do
  desc 'Populate the database with saphyr tubes and runs'
  task create: :environment do
    external_study_id = SecureRandom.uuid

    # attributes = { sample: { name: "Sample#{i}", external_id: SecureRandom.uuid, species: "Species#{i}" }, requestable: { external_stud_id: }}

    attributes = (1..5).collect do |i|
      { sample: { name: "SaphyrSample#{i}", external_id: SecureRandom.uuid, species: "Species#{i}" }, request: { external_study_id: } }
    end

    factory = Saphyr::RequestFactory.new(attributes)
    factory.save

    # binding.pry

    Saphyr::Request.all.each do |request|
      library = Saphyr::Library.create!(request:, saphyr_enzyme_id: 1)
      ContainerMaterial.create(container: Tube.create, material: library)
      chip = Saphyr::Chip.create!(barcode: 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX')
      (1..2).each do |n|
        chip.flowcells << Saphyr::Flowcell.create(position: n, library:)
      end
      chip.save
      Saphyr::Run.create!(chip:)
    end
    puts '-> Saphyr runs successfully created'
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Saphyr::Request'
    end
    [Saphyr::Request, Saphyr::Library, Saphyr::Flowcell, Saphyr::Chip, Saphyr::Run].each(&:delete_all)
    puts '-> Saphyr runs successfully deleted'
  end
end
