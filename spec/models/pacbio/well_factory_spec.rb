# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pacbio::WellFactory, type: :model, pacbio: true do

  let(:plate)           { create(:pacbio_plate) }
  let(:libraries)       { create_list(:pacbio_library, 3) }
  let(:wells_attributes) {
                          [
                            attributes_for(:pacbio_well).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries.first.id}]),
                            attributes_for(:pacbio_well).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries[1].id}]),
                            attributes_for(:pacbio_well).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries.last.id}])
                        ]}

  context 'WellFactory' do
    context '#initialize' do
      it 'creates a list of WellFactory::Wells' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.wells.count).to eq(3)
        expect(factory.wells[0].class).to eq Pacbio::WellFactory::Well
        expect(factory.wells[1].class).to eq Pacbio::WellFactory::Well
        expect(factory.wells[2].class).to eq Pacbio::WellFactory::Well
      end

      it 'creates a well for each WellFactory::Well' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.wells[0].well).to be_present
        expect(factory.wells[1].well).to be_present
        expect(factory.wells[2].well).to be_present
      end
    end

    context '#plate' do
      it 'sets the default plate of the wells' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory.plate.id).to eq(wells_attributes[0][:plate][:id])
      end
    end

    context '#save' do
      it 'will save the wells if they are valid' do
        factory = Pacbio::WellFactory.new(wells_attributes)
        expect(factory).to be_valid
        expect(factory.save).to be_truthy
      end

      it 'will call the WellFactory:Well save if wells are valid' do
        factory = Pacbio::WellFactory.new(wells_attributes)

        expect(factory.wells[0]).to receive(:save)
        expect(factory.wells[1]).to receive(:save)
        expect(factory.wells[2]).to receive(:save)

        factory.save
      end

      it 'will not save the wells if they are not valid' do
        factory = Pacbio::WellFactory.new([])
        expect(factory).to_not be_valid
        expect(factory.save).to be_falsey
        expect(factory.errors.messages[:wells]).to eq ['there are no wells']
      end
    end

    context '#errors' do
      context 'when the error is the in WellFactory' do
        it 'returns the correct error message' do
          factory = Pacbio::WellFactory.new([])
          factory.save
          expect(factory.errors.messages[:wells]).to eq ['there are no wells']
        end
      end

      context 'when the error is the in WellFactory:Well' do
        let(:wells_attributes_well_error)  {
                                  [ attributes_for(:pacbio_well).except(:movie_time).except(:plate).merge( plate: {type: 'plate', id: plate.id}, libraries: [{type: 'libraries', id: libraries.first.id}]) ]
                                }

        it 'returns the correct error message' do
          factory = Pacbio::WellFactory.new(wells_attributes_well_error)
          factory.save
          expect(factory.errors.messages[:movie_time]).to eq ["can't be blank", "is not a number"]
        end
      end

      context 'when the error is the in WellFactory:Well:Libraries' do
        let(:library) { create(:pacbio_library_with_tag) }

        let(:libraries_attributes_dupl_tags) do
          [{ type: 'libraries', id: library.id }, { type: 'libraries', id: library.id }]
        end

        let(:wells_attributes_libraries_error)  {
                                                  [ attributes_for(:pacbio_well).merge(
                                                    plate: { type: 'plate', id: plate.id },
                                                    libraries: libraries_attributes_dupl_tags
                                                  ) ]
                                                }

        it 'returns the correct error message' do
          factory = Pacbio::WellFactory.new(wells_attributes_libraries_error)
          factory.save
          expect(factory.errors.messages[:tags][0]).to include 'are not unique within the libraries for well'
        end
      end
    end
  end

  context 'WellFactory::Well' do
    let(:library1)             { create(:pacbio_library_with_tag) }
    let(:library2)             { create(:pacbio_library_with_tag) }
    let(:library_attributes)            { [
                                          { type: 'libraries', id: library1.id },
                                          { type: 'libraries', id: library2.id }
                                        ] }
    let(:well_attributes)               { attributes_for(:pacbio_well).except(:plate).merge(
                                          plate: { type: 'plate', id: plate.id },
                                          libraries: library_attributes )
                                        }

    context '#initialize' do
      context 'when the wells dont exist' do

        it 'builds the Pacbio::Well' do
          factory = Pacbio::WellFactory::Well.new(well_attributes)
          expect(factory.well.class).to eq Pacbio::Well
          expect(factory.well.id).to eq nil
          expect(factory.well.movie_time).to eq well_attributes[:movie_time]
          expect(factory.well.insert_size).to eq well_attributes[:insert_size].to_i
          expect(factory.well.on_plate_loading_concentration).to eq well_attributes[:on_plate_loading_concentration].to_f
          expect(factory.well.row).to eq well_attributes[:row]
          expect(factory.well.column).to eq well_attributes[:column]
          expect(factory.well.comment).to eq well_attributes[:comment]
        end

        it 'creates a list of WellFactory::Well::Libraries' do
          factory = Pacbio::WellFactory::Well.new(well_attributes)
          expect(factory.libraries.class).to eq Pacbio::WellFactory::Well::Libraries
          expect(factory.libraries.libraries.length).to eq(2)
        end

        it 'sets the Pacbio::Well plate' do
          factory = Pacbio::WellFactory::Well.new(well_attributes)
          expect(factory.well.plate).to eq plate
        end

        it 'produces an error message if the plate doesnt exist' do
          well_attributes_no_plate = attributes_for(:pacbio_well).except(:plate).merge( libraries: [{type: 'libraries', id: libraries.last.id}])
          factory = Pacbio::WellFactory::Well.new(well_attributes_no_plate)
          expect(factory).to_not be_valid
          expect(factory.errors.full_messages).to include 'Plate must exist'
        end

        it 'creates the well with no libraries, when libraries arent included' do
          well_with_no_libraries = well_attributes.except(:libraries)
          factory = Pacbio::WellFactory::Well.new(well_with_no_libraries)

          expect(factory.well.id).to eq nil
          expect(factory.well.libraries.length).to eq(0)
        end
      end

      context 'when the wells do exist' do
        let(:well_with_libraries)                { create(:pacbio_well_with_libraries) }
        let(:new_library1) { create(:pacbio_library) }
        let(:new_library2) { create(:pacbio_library) }
        let(:updated_well_attributes)  { { id: well_with_libraries.id, insert_size: 123, on_plate_loading_concentration: 12, libraries: [ { type: 'libraries', id: new_library1.id }, { type: 'libraries', id: new_library2.id } ] } }

        it 'updates the Pacbio::Well' do
          factory = Pacbio::WellFactory::Well.new(updated_well_attributes)
          expect(factory.well.id).to eq well_with_libraries.id
          expect(factory.well.movie_time).to eq well_with_libraries[:movie_time]
          expect(factory.well.insert_size).to eq updated_well_attributes[:insert_size].to_i
          expect(factory.well.on_plate_loading_concentration).to eq updated_well_attributes[:on_plate_loading_concentration].to_f
          expect(factory.well.row).to eq well_with_libraries[:row]
          expect(factory.well.column).to eq well_with_libraries[:column]
          expect(factory.well.comment).to eq well_with_libraries[:comment]
        end

        it 'creates a list of WellFactory::Well::Libraries' do
          factory = Pacbio::WellFactory::Well.new(updated_well_attributes)
          expect(factory.libraries.class).to eq Pacbio::WellFactory::Well::Libraries
          expect(factory.libraries.libraries.length).to eq(2)
          expect(factory.libraries.libraries[0].id).to eq new_library1.id
          expect(factory.libraries.libraries[1].id).to eq new_library2.id
        end
      end
    end

    context '#save' do
      it 'creates the wells, if each well is valid' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        expect(factory).to be_valid
        expect { factory.save }.to change(Pacbio::Well, :count).by(1)
      end

      it 'will call the WellFactory:Well::Libraries save if wells are valid' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        expect(factory.libraries).to receive(:save)

        factory.save
      end

      it 'wont create the wells, if any well is invalid' do
        well_attributes_no_movie_time = well_attributes.except(:movie_time)
        factory = Pacbio::WellFactory::Well.new(well_attributes_no_movie_time)
        expect(factory).to_not be_valid
        expect { factory.save }.to change(Pacbio::Well, :count).by(0)
        expect(factory.errors.messages[:movie_time]).to eq ["can't be blank", "is not a number"]
      end
    end

    context '#libraries' do
      it 'creates a list of WellFactory::Well::Libraries' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        expect(factory.libraries.class).to eq Pacbio::WellFactory::Well::Libraries
        expect(factory.libraries.libraries.length).to eq(2)
      end
    end

    context '#id' do
      it 'returns the Pacbio::Well id' do
        factory = Pacbio::WellFactory::Well.new(well_attributes)
        factory.save
        expect(factory.id).to eq Pacbio::Well.last.id
      end
    end
  end

  context 'WellFactory::Well::Libraries' do
    let(:well)                          { create(:pacbio_well) }
    let(:library1)                      { create(:pacbio_library_with_tag) }
    let(:library2)                      { create(:pacbio_library_with_tag) }
    let(:library_invalid)               { create(:pacbio_library, tag: library1.tag) }
    let(:library_attributes)            { [
                                          { type: 'libraries', id: library1.id },
                                          { type: 'libraries', id: library2.id }
                                        ] }
    let(:libraries_attributes_no_tags)  { [
                                          { type: 'libraries', id: libraries[0].id},
                                          { type: 'libraries', id: libraries[1].id }
                                        ] }
    let(:library_attributes_dupl_tags)  { library_attributes.push(
                                          { type: 'libraries', id: library_invalid.id }
                                        ) }
    let(:library_attributes_17)         { create_list(:pacbio_library, 17, request_libraries: [
                                          create(:pacbio_request_library_with_tag)
                                        ]) }
    let(:library_attributes_fake)       { [ { type: 'libraries', id: 123 } ] }

    context '#initialize' do
      it 'creates a list of Pacbio::Library' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, library_attributes)
        expect(factory.libraries.count).to eq(library_attributes.length)
        expect(factory.libraries[0].class).to eq Pacbio::Library
        expect(factory.libraries[1].class).to eq Pacbio::Library
      end
    end

    context '#libraries' do
      it 'contains a list of Pacbio::Library' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, library_attributes)
        expect(factory.libraries.count).to eq(library_attributes.length)
      end
    end

    context '#well' do
      it 'contains the given Pacbio::Well' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, library_attributes)
        expect(factory.well).to eq(well)
      end
    end

    context '#save' do
      it 'updates the wells libaries, if libraries are valid' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, library_attributes)
        expect(factory).to be_valid
        expect(factory.save).to be_truthy
        expect(well.libraries.length).to eq library_attributes.length
        expect(well.libraries[0].id).to eq library_attributes[0][:id]
        expect(well.libraries[1].id).to eq library_attributes[1][:id]
      end

      it 'does not update the well libaries, if libraries are invalid - check_tags_present' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, libraries_attributes_no_tags)
        expect(factory).not_to be_valid
        expect(factory.save).not_to be_truthy
        expect(factory.errors.messages[:tags]).to eq ["are missing from the libraries"]
      end

      it 'does not update the well libaries, if libraries are invalid - check_tags_uniq' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, library_attributes_dupl_tags)
        expect(factory).not_to be_valid
        expect(factory.save).not_to be_truthy
        expect(factory.errors.messages[:tags]).to eq ["are not unique within the libraries for well " + well.position]
      end

      it 'does not update the well libaries, if libraries are invalid - check_libraries_max' do
        factory = Pacbio::WellFactory::Well::Libraries.new(well, library_attributes_17)
        expect(factory).not_to be_valid
        expect(factory.save).not_to be_truthy
        expect(factory.errors.messages[:libraries]).to eq ["There are more than 16 libraries in well " + well.position]
      end
    end

  end
end
