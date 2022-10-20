# frozen_string_literal: true

require 'csv'

namespace :migrate_saphyr_data do
  task create_runs: :environment do |_t|
    # samples and requests
    table = CSV.parse(Rails.root.join('lib/data/saphyr_samples.csv').read, headers: true)
    table.each do |row|
      created_at = Date.parse(row['created_at'])
      sample = Sample.create!(name: row['name'], species: row['species'], external_id: row['external_id'], created_at:)
      request = Saphyr::Request.create!(sample:, external_study_id: row['external_study_id'], created_at:)
      ContainerMaterial.create(container: Tube.create, material: request)
    end

    # libraries
    table = CSV.parse(Rails.root.join('lib/data/saphyr_libraries.csv').read, headers: true)
    table.each do |row|
      sample = Sample.find_by(name: row['sample_name'])
      library = Saphyr::Library.create!(request: sample.requests.first.requestable, enzyme: Saphyr::Enzyme.find_by(name: row['enzyme']), created_at: Date.parse(row['created_at']))
      ContainerMaterial.create(container: Tube.create, material: library)
    end

    # runs
    table = CSV.parse(Rails.root.join('lib/data/saphyr_runs.csv').read, headers: true)
    table.each do |row|
      created_at = Date.parse(row['created_at'])
      run = Saphyr::Run.create!(state: 2, created_at:)
      chip = Saphyr::Chip.create!(barcode: row['chip_barcode'], run:, created_at:)

      # flowcell1
      sample = Sample.find_by(name: row['flowcell_1_sample_name'])
      request = sample.requests.first.requestable
      enzyme = Saphyr::Enzyme.find_by(name: row['flowcell_1_enzyme'])
      library = request.libraries.find_by(saphyr_enzyme_id: enzyme.id)
      flowcell = Saphyr::Flowcell.create(position: 1, chip:, library:, created_at:)
      Messages.publish(flowcell, Pipelines.saphyr.message)

      # flowcell2
      sample = Sample.find_by(name: row['flowcell_2_sample_name'])
      request = sample.requests.first.requestable
      enzyme = Saphyr::Enzyme.find_by(name: row['flowcell_2_enzyme'])
      library = request.libraries.find_by(saphyr_enzyme_id: enzyme.id)
      flowcell = Saphyr::Flowcell.create(position: 2, chip:, library:, created_at:)
      Messages.publish(flowcell, Pipelines.saphyr.message)
    end
  end

  task destroy: :environment do |_t|
    [Sample, Request, Saphyr::Request, Saphyr::Library, Saphyr::Flowcell, Saphyr::Chip, Saphyr::Run].each(&:delete_all)
  end
end
