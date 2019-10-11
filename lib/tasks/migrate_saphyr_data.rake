# frozen_string_literal: true

require 'csv'

namespace :migrate_saphyr_data do
  task create_runs: :environment do |_t|
    # samples and requests
    table = CSV.parse(File.read(Rails.root.join('lib', 'data', 'saphyr_samples.csv')), headers: true)
    table.each do |row|
      sample = Sample.create!(name: row['sample_name'], species: row['species_name'], external_id: row['external_id'], created_at: Date.parse(row['created_at']))
      p sample
      request = Saphyr::Request.create!(sample: sample, external_study_id: row['external_study_id'], created_at: Date.parse(row['created_at']), tube: Tube.new)
      p request
    end

    # libraries
    table = CSV.parse(File.read(Rails.root.join('lib', 'data', 'saphyr_libraries.csv')), headers: true)
    table.each do |row|
      sample = Sample.find_by(name: row['sample_name'])
      library = Saphyr::Library.create!(request: sample.requests.first.requestable, enzyme: Saphyr::Enzyme.find_by(name: row['enzyme']), created_at: Date.parse(row['created_at']), tube: Tube.new)
      p library
    end

    # runs
    table = CSV.parse(File.read(Rails.root.join('lib', 'data', 'saphyr_runs.csv')), headers: true)
    table.each do |row|
      run = Saphyr::Run.create!(state: 2, created_at: Date.parse(row['created_at']))
      p run
      chip = Saphyr::Chip.create!(barcode: row['chip_barcode'], run: run, created_at: Date.parse(row['created_at']))
      p chip

      # flowcell1
      sample = Sample.find_by(name: row['flowcell_1_sample_name'])
      request = sample.requests.first.requestable
      enzyme = Saphyr::Enzyme.find_by(name: row['flowcell_1_enzyme'])
      library = request.libraries.find_by(saphyr_enzyme_id: enzyme.id)
      flowcell = Saphyr::Flowcell.create(position: 1, chip: chip, library: library, created_at: Date.parse(row['created_at']))
      p flowcell

      # flowcell2
      sample = Sample.find_by(name: row['flowcell_2_sample_name'])
      request = sample.requests.first.requestable
      enzyme = Saphyr::Enzyme.find_by(name: row['flowcell_2_enzyme'])
      library = request.libraries.find_by(saphyr_enzyme_id: enzyme.id)
      flowcell = Saphyr::Flowcell.create(position: 2, chip: chip, library: library, created_at: Date.parse(row['created_at']))
      p flowcell
    end
  end

  task destroy: :environment do |_t|
    [Sample, Request, Saphyr::Request, Saphyr::Library, Saphyr::Flowcell, Saphyr::Chip, Saphyr::Run].each(&:delete_all)
  end
end
