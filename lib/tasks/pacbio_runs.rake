# frozen_string_literal: true

namespace :pacbio_runs do
  task create: :environment do
    attributes = (6..10).collect do |i|
      { name: "Sample#{i}", external_id: 'DEA103A3484', external_study_id: 4086,
        library_type: "LibraryType#{i}", estimate_of_gb_required: 10, number_of_smrt_cells: 3, cost_code: 'PSD12345', species: "Species#{i}" }
    end

    factory = Pacbio::RequestFactory.new(attributes)
    factory.save

    Pacbio::Request.all.each_with_index do |request, i|
      library = Pacbio::Library.create!(volume: 1, concentration: 1, library_kit_barcode: 'LK12345', fragment_size: 100, tube: Tube.create)
      Pacbio::RequestLibrary.create!(library: library, request: request, tag: Tag.find(rand(1..16)))
      run = Pacbio::Run.create!(name: "Run#{i}", template_prep_kit_box_barcode: "TPK#{i}", binding_kit_box_barcode: "BKB#{i}",
                                sequencing_kit_box_barcode: "SKB#{i}", dna_control_complex_box_barcode: "DCCB#{i}")
      plate = Pacbio::Plate.create!(run: run)
      Pacbio::Well.create!(plate: plate, libraries: [library], movie_time: 20, insert_size: 10, on_plate_loading_concentration: 1,
                           row: 'A', column: i + 1, sequencing_mode: 'CLR')
    end
    puts '-> Pacbio runs successfully created'
  end

  task destroy: :environment do
    Sample.all.each do |sample|
      sample.destroy if sample.requests[0].requestable_type == 'Pacbio::Request'
    end
    [Pacbio::Request, Pacbio::Library, Pacbio::Run, Pacbio::Plate, Pacbio::Well,
     Pacbio::WellLibrary, Pacbio::RequestLibrary].each(&:delete_all)
    puts '-> Pacbio runs successfully deleted'
  end
end
