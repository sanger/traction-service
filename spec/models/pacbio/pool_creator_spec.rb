# require 'rails_helper'

# RSpec.describe Pacbio::PoolCreator, type: :model, pacbio: true do
#   let(:libraries) { build_list(:pacbio_library, 5) }
#   let(:libraries_attributes) { libraries.collect(&:attributes) }
#   let(:invalid_library) { build(:pacbio_library, volume: nil) }
#   let(:pool_attributes) { { template_prep_kit_box_barcode: 'ABC1', volume: 1, concentration: 1, fragment_size: 100} }

#   context '#initialize' do
#     let(:pool_creator) { Pacbio::PoolCreator.new(pool_attributes.merge(libraries: libraries_attributes)) }

#     it 'will have a pool' do
#       expect(pool_creator.pool).to be_present
#     end

#     context 'pool' do
#       let(:pool) { pool_creator.pool }

#       it 'will have a tube' do
#         expect(pool.tube).to be_present
#       end

#       it 'will have some libraries' do
#         expect(pool.libraries.length).to eq(libraries.length)
#       end

#       it 'will have a template prep kit box barcode' do
#         expect(pool.template_prep_kit_box_barcode).to eq(pool_attributes[:template_prep_kit_box_barcode])
#       end

#       it 'will have a concentration' do
#         expect(pool.concentration).to eq(pool_attributes[:concentration])
#       end

#       it 'will have a volume' do
#         expect(pool.volume).to eq(pool_attributes[:volume])
#       end

#       it 'will have a fragment size' do
#         expect(pool.fragment_size).to eq(pool_attributes[:fragment_size])
#       end

#     end

#     context 'a library' do

#       let(:library) { pool_creator.pool.libraries.first }

#       it 'will have a volume' do
#         expect(library.volume).to eq(libraries.first.volume)
#       end

#       it 'will have a concentration' do
#         expect(library.concentration).to eq(libraries.first.concentration)
#       end

#       it 'will have a template prep kit box barcode' do
#         expect(library.template_prep_kit_box_barcode).to eq(libraries.first.template_prep_kit_box_barcode)
#       end

#       it 'will have a fragment size' do
#         expect(library.fragment_size).to eq(libraries.first.fragment_size)
#       end

#       it 'will have a request' do
#         expect(library.request).to eq(libraries.first.request)
#       end

#       it 'will have a tag' do
#         expect(library.tag).to eq(libraries.first.tag)
#       end

#     end

#   end

#   context '#valid' do

#     it 'will not be valid unless there are some libraries' do
#       pool_creator =  Pacbio::PoolCreator.new
#       expect(pool_creator).to_not be_valid
#     end

#     it 'will not be valid unless the libraries are valid' do
#       pool_creator =  Pacbio::PoolCreator.new(libraries: libraries_attributes + [invalid_library.attributes])
#       expect(pool_creator).to_not be_valid
#     end
#   end

#   context '#save' do

#     context 'valid' do

#       let(:pool_creator) { Pacbio::PoolCreator.new(libraries: libraries_attributes)}

#       it 'will create a pool' do
#         expect(pool_creator.save!).to be_truthy
#         expect(pool_creator.pool).to be_persisted
#       end

#       it 'will create the libraries' do
#         expect(pool_creator.save!).to be_truthy
#         expect(pool_creator.pool.libraries.all?(&:persisted?)).to be_truthy
#       end
#     end

#     context 'invalid' do

#       let(:pool_creator) { Pacbio::PoolCreator.new(libraries: libraries_attributes + [invalid_library.attributes]) }

#       # I know this is arbitrary!
#       it 'will not save anything' do
#         expect(pool_creator.save!).to be_falsey
#         expect(pool_creator.pool).to_not be_persisted
#       end

#       it 'will create some errors' do
#         expect(pool_creator.save!).to be_falsey
#         expect(pool_creator.errors).to_not be_empty
#       end

#     end

#   end
# end
