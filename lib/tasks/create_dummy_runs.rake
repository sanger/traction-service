# frozen_string_literal: true

namespace :dummy_runs do
  task create: :environment do |_t|
    (1..5).each do |i|
      sample = Sample.create(name: "Sample#{i}", sequencescape_request_id: i, species: "Species#{i}", tube: Tube.create)
      library = Library.create(sample: sample, enzyme_id: i, tube: Tube.create)
      chip = Chip.create
      chip.flowcells.first.library = library
      chip.flowcells.last.library = library
      chip.save
      Run.create(chip: chip)
    end
  end

  task destroy: :environment do |_t|
    Library.delete_all
    Flowcell.delete_all
    Chip.delete_all
    Sample.delete_all
    Run.delete_all
  end
end
