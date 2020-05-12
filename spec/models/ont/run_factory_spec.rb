require 'rails_helper'

RSpec.describe Ont::RunFactory, type: :model, ont: true do
  context '#initialise' do
    it 'is invalid if run is invalid' do
      errors = ActiveModel::Errors.new(Ont::Run.new)
      errors.add('run', message: 'This is a test error')
      allow_any_instance_of(Ont::Run).to receive(:valid?).and_return(false)
      allow_any_instance_of(Ont::Run).to receive(:errors).and_return(errors)
      factory = Ont::RunFactory.new([])
      expect(factory).to_not be_valid
    end

    it 'is invalid if any flowcell is invalid' do
      errors = ActiveModel::Errors.new(Ont::Flowcell.new)
      errors.add('run', message: 'This is a test error')
      allow_any_instance_of(Ont::Flowcell).to receive(:valid?).and_return(false)
      allow_any_instance_of(Ont::Flowcell).to receive(:errors).and_return(errors)
      factory = Ont::RunFactory.new([{ position: 1, library_name: 'PLATE-2-1234-2' }])
      expect(factory).to_not be_valid
    end
  end

  context '#save' do
    context 'valid build' do
      context 'with no flowcells' do
        it 'creates a run' do
          factory = Ont::RunFactory.new([])
          factory.save
          expect(Ont::Run.count).to eq(1)
        end

        it 'creates no flowcells' do
          factory = Ont::RunFactory.new([])
          factory.save
          expect(Ont::Flowcell.count).to eq(0)
        end

        context 'validates' do
          let!(:run) { create(:ont_run) }
          let!(:flowcell) { create(:ont_flowcell) }

          it 'the run exactly once' do
            allow(Ont::Run).to receive(:new).and_return(run)
            expect(run).to receive(:valid?).exactly(1)
            factory = Ont::RunFactory.new([])
            factory.save
          end

          it 'no flowcells' do
            allow(Ont::Flowcell).to receive(:new).and_return(flowcell)
            expect(flowcell).to receive(:valid?).exactly(0)
            factory = Ont::RunFactory.new([])
            factory.save
          end
        end

        context 'without validation' do
          let!(:run) { create(:ont_run) }
          let!(:flowcell) { create(:ont_flowcell) }

          it 'does not validate created run' do
            allow(Ont::Run).to receive(:new).and_return(run)
            expect(run).to_not receive(:valid?)
            factory = Ont::RunFactory.new([])
            factory.save(validate: false)
          end

          it 'does not validate any flowcells' do
            allow(Ont::Flowcell).to receive(:new).and_return(flowcell)
            expect(flowcell).to_not receive(:valid?)
            factory = Ont::RunFactory.new([])
            factory.save(validate: false)
          end
        end
      end
      
      context 'with flowcells' do
        let!(:libraries) { create_list(:ont_library, 3).each_with_index do |library, idx|
          library.update(name: "library number #{idx + 1}")
        end }
        let!(:attributes) { libraries.collect(&:name).each_with_index.map { |name, idx| { position: idx + 1, library_name: name } } }

        it 'creates a run' do
          factory = Ont::RunFactory.new(attributes)
          factory.save
          expect(Ont::Run.count).to eq(1)
        end

        it 'creates expected flowcells' do
          factory = Ont::RunFactory.new(attributes)
          factory.save
          expect(Ont::Flowcell.count).to eq(3)
          expect(Ont::Flowcell.all.map { |flowcell| flowcell.run }).to all( eq(Ont::Run.first) )

          expect(Ont::Flowcell.first.position).to eq(1)
          expect(Ont::Flowcell.first.library).to eq(Ont::Library.find_by(name: libraries.first.name))
          expect(Ont::Flowcell.second.position).to eq(2)
          expect(Ont::Flowcell.second.library).to eq(Ont::Library.find_by(name: libraries.second.name))
          expect(Ont::Flowcell.third.position).to eq(3)
          expect(Ont::Flowcell.third.library).to eq(Ont::Library.find_by(name: libraries.third.name))
        end

        context 'validates' do
          let!(:run) { create(:ont_run) }
          let!(:flowcell) { create(:ont_flowcell) }

          it 'the run exactly once' do
            allow(Ont::Run).to receive(:new).and_return(run)
            expect(run).to receive(:valid?).exactly(1)
            factory = Ont::RunFactory.new(attributes)
            factory.save
          end

          it 'each flowcell exactly once' do
            allow(Ont::Flowcell).to receive(:new).and_return(flowcell)
            expect(flowcell).to receive(:valid?).exactly(3)
            factory = Ont::RunFactory.new(attributes)
            factory.save
          end
        end

        context 'without validation' do
          let!(:run) { create(:ont_run) }
          let!(:flowcell) { create(:ont_flowcell) }

          it 'does not validate created run' do
            allow(Ont::Run).to receive(:new).and_return(run)
            expect(run).to_not receive(:valid?)
            factory = Ont::RunFactory.new(attributes)
            factory.save(validate: false)
          end

          it 'does not validate any flowcells' do
            allow(Ont::Flowcell).to receive(:new).and_return(flowcell)
            expect(flowcell).to_not receive(:valid?)
            factory = Ont::RunFactory.new(attributes)
            factory.save(validate: false)
          end
        end
      end
    end

    context 'invalid build' do
      before do
        errors = ActiveModel::Errors.new(Ont::Run.new)
        errors.add('run', message: 'This is a test error')
        allow_any_instance_of(Ont::Run).to receive(:valid?).and_return(false)
        allow_any_instance_of(Ont::Run).to receive(:errors).and_return(errors)
      end

      it 'returns false on save' do
        factory = Ont::RunFactory.new([])
        expect(factory.save).to be_falsey
      end

      it 'does not create any runs' do
        factory = Ont::RunFactory.new([])
        factory.save
        expect(Ont::Run.count).to eq(0)
      end
  
      it 'does not create any flowcells' do
        factory = Ont::RunFactory.new([])
        factory.save
        expect(Ont::Flowcell.count).to eq(0)
      end
    end
  end
end
