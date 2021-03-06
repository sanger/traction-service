# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Performance testing' do
  context 'creating ont plate' do
    def plate_with_ont_samples(num_wells, samples_per_well, tag_oligo)
      {
        barcode: 'test barcode',
        wells: (1..num_wells).map do |well_idx|
          {
            position: well_idx.to_s,
            samples: ont_samples(samples_per_well, tag_oligo)
          }
        end
      }
    end

    def ont_samples(samples_per_well, tag_oligo)
      (1..samples_per_well).map do |sample_idx|
        {
          name: "sample #{sample_idx}",
          external_id: "ext-#{sample_idx}",
          tag_oligo: tag_oligo
        }
      end
    end

    #
    # Records the time taken to execute the block in seconds. Uses Process::CLOCK_MONOTONIC
    # so is not affected by updates to the system-clock.
    # @see https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
    # Also @see https://www.rubydoc.info/stdlib/core/Process:clock_gettime
    #
    # @return [Integer,Float] Time elapsed in unit
    #
    def benchmark(unit: :millisecond)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, unit)
      yield
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, unit)
      end_time - start_time
    end

    context 'with 96 wells' do
      let(:num_wells) { 96 }
      let(:tag_set) { create(:tag_set_with_tags, number_of_tags: num_wells) }

      before do
        allow(Pipelines::ConstantsAccessor).to receive(:ont_covid_pcr_tag_set_name)
          .and_return(tag_set.name)
      end

      context 'each with 1 sample' do
        let(:num_samples) { 1 }

        it 'is performant' do
          attributes = plate_with_ont_samples(num_wells, num_samples, tag_set.tags.first.oligo)

          time_taken_milli = benchmark do
            factory = Ont::PlateWithSamplesFactory.new(attributes)
            factory.process
            expect(factory.save).to be_truthy
          end
          expect(time_taken_milli).to be < 500
        end
      end

      context 'each with 96 samples' do
        let(:num_samples) { 96 }

        it 'is performant' do
          attributes = plate_with_ont_samples(num_wells, num_samples, tag_set.tags.first.oligo)

          time_taken_milli = benchmark do
            factory = Ont::PlateWithSamplesFactory.new(attributes)
            factory.process
            expect(factory.save).to be_truthy
          end

          expect(time_taken_milli).to be < 5000
        end
      end

      context 'each with 384 samples' do
        let(:num_samples) { 384 }

        it 'is performant' do
          attributes = plate_with_ont_samples(num_wells, num_samples, tag_set.tags.first.oligo)

          time_taken_milli = benchmark do
            factory = Ont::PlateWithSamplesFactory.new(attributes)
            factory.process
            expect(factory.save).to be_truthy
          end

          expect(time_taken_milli).to be < 20000
        end
      end
    end
  end
end
