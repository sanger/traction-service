# frozen_string_literal: true

namespace :dummy_runs do
  task create: :environment do |_t|
    # Saphyr
    attributes = (1..5).collect { |i| { name: "Sample#{i}", external_id: i, external_study_id: i, species: "Species#{i}" } }

    factory = Saphyr::RequestFactory.new(attributes)
    factory.save

    Saphyr::Request.all.each_with_index do |request, i|
      library = Saphyr::Library.create!(request: request, saphyr_enzyme_id: i + 1, tube: Tube.create)
      chip = Saphyr::Chip.create!(barcode: 'FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX')
      (1..2).each do |n|
        chip.flowcells << Saphyr::Flowcell.create(position: n, library: library)
      end
      chip.save
      Saphyr::Run.create!(chip: chip)
    end

    # Pacbio
    attributes = (6..10).collect do |i|
      { name: "Sample#{i}", external_id: 'DEA103A3484', external_study_id: 4086,
        library_type: "LibraryType#{i}", estimate_of_gb_required: 10, number_of_smrt_cells: 3, cost_code: 'PSD12345', species: "Species#{i}" }
    end

    factory = Pacbio::RequestFactory.new(attributes)
    factory.save

    tag = Tag.create!(oligo: 'ATGC', group_id: 1, set_name: 'pacbio')

    Pacbio::Request.all.each_with_index do |request, i|
      library = Pacbio::Library.create!(volume: 1, concentration: 1, library_kit_barcode: 'LK12345', fragment_size: 100, tube: Tube.create)
      Pacbio::RequestLibrary.create!(library: library, request: request, tag: tag)
      run = Pacbio::Run.create!(name: "Run#{i}", template_prep_kit_box_barcode: "TPK#{i}", binding_kit_box_barcode: "BKB#{i}",
                                sequencing_kit_box_barcode: "SKB#{i}", dna_control_complex_box_barcode: "DCCB#{i}")
      plate = Pacbio::Plate.create!(run: run, barcode: "PLATE-#{i}")
      Pacbio::Well.create!(plate: plate, libraries: [library], movie_time: 1, insert_size: 10, on_plate_loading_concentration: 1,
                           row: i, column: i, sequencing_mode: 'CLR')
    end
  end

  task destroy: :environment do |_t|
    [Sample, Request, Pacbio::Request, Pacbio::Library, Pacbio::Run, Pacbio::Plate, Pacbio::Well,
     Pacbio::Tag, Saphyr::Request, Saphyr::Library, Saphyr::Flowcell, Saphyr::Chip, Saphyr::Run,
     Pacbio::WellLibrary, Pacbio::RequestLibrary].each(&:delete_all)
  end
end
