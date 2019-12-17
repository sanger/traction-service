# frozen_string_literal: true

namespace :saphyr_runs do

  task create: :environment do
    attributes = (1..5).collect { |i| { name: "Sample#{i}", external_id: i, external_study_id: i, species: "Species#{i}" } }

    factory = Saphyr::RequestFactory.new(attributes)
    factory.save

    Saphyr::Request.all.each_with_index do |request, i|
      library = Saphyr::Library.create!(request: request, saphyr_enzyme_id: 1, tube: Tube.create)
      chip = Saphyr::Chip.create!(barcode: 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX')
      (1..2).each do |n|
        chip.flowcells << Saphyr::Flowcell.create(position: n, library: library)
      end
      chip.save
      Saphyr::Run.create!(chip: chip)
    end
  end

  task destroy: :environment do
    Sample.all.each{|sample| sample.destroy if sample.requests[0].requestable_type == "Saphyr::Request"}
    [Saphyr::Request, Saphyr::Library, Saphyr::Flowcell,Saphyr::Chip, Saphyr::Run].each(&:delete_all)
  end

end
