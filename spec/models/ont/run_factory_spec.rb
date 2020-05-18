# frozen_string_literal: true

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

    context 'with valid flowcell specs' do
      let(:library) { create(:ont_library) }

      it 'is a valid factory when no existing run provided' do
        factory = Ont::RunFactory.new([{ position: 1, library_name: library.name }])
        expect(factory).to be_valid
      end

      it 'is a valid factory when an existing run is provided' do
        run = create(:ont_run)
        factory = Ont::RunFactory.new([{ position: 1, library_name: library.name }], run)
        expect(factory).to be_valid
      end

      it 'updates an existing run with new flowcells' do
        run = create(:ont_run)
        existing_flowcell_ids = run.flowcells.map(&:id)
        Ont::RunFactory.new([{ position: 1, library_name: library.name }], run)
        new_flowcell_ids = run.flowcells.map(&:id)
        expect(new_flowcell_ids - existing_flowcell_ids).to match_array(new_flowcell_ids)
      end
    end
  end

  context '#save' do
    context 'valid build' do
      context 'with no flowcells' do
        context 'with no existing run supplied' do
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
        end

        context 'with existing run supplied' do
          let(:run) { create(:ont_run) }

          it 'saves the existing run' do
            expect(run).to receive(:save)
            factory = Ont::RunFactory.new([], run)
            factory.save
            expect(Ont::Run.count).to eq(1)
          end

          it "replaces the run's flowcells with none" do
            expect(run.flowcells.count).to be > 0
            factory = Ont::RunFactory.new([], run)
            factory.save
            expect(run.flowcells.count).to eq(0)
          end

          it 'destroys the old flowcells' do
            run.flowcells.each do |fc|
              expect(fc).to receive(:destroy)
            end
            factory = Ont::RunFactory.new([], run)
            factory.save
          end
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
        let!(:libraries) do
          create_list(:ont_library, 3).each_with_index do |library, idx|
            library.update(name: "library number #{idx + 1}")
          end
        end

        let!(:attributes) do
          libraries.collect(&:name).each_with_index.map do |name, idx|
            { position: idx + 1, library_name: name }
          end
        end

        context 'with no existing run supplied' do
          it 'creates a run' do
            factory = Ont::RunFactory.new(attributes)
            factory.save
            expect(Ont::Run.count).to eq(1)
          end

          it 'creates expected flowcells' do
            factory = Ont::RunFactory.new(attributes)
            factory.save
            expect(Ont::Flowcell.count).to eq(3)
            expect(Ont::Flowcell.all.map(&:run)).to all(eq(Ont::Run.first))

            expect(Ont::Flowcell.first.position).to eq(1)
            expect(Ont::Flowcell.first.library)
              .to eq(Ont::Library.find_by(name: libraries.first.name))
            expect(Ont::Flowcell.second.position).to eq(2)
            expect(Ont::Flowcell.second.library)
              .to eq(Ont::Library.find_by(name: libraries.second.name))
            expect(Ont::Flowcell.third.position).to eq(3)
            expect(Ont::Flowcell.third.library)
              .to eq(Ont::Library.find_by(name: libraries.third.name))
          end
        end

        context 'with existing run supplied' do
          let(:run) { create(:ont_run) }

          it 'saves the existing run' do
            expect(run).to receive(:save)
            factory = Ont::RunFactory.new(attributes, run)
            factory.save
            expect(Ont::Run.count).to eq(1)
          end

          it "replaces the run's flowcells with new from attributes" do
            initial_flowcell_ids = run.flowcells.map(&:id)
            factory = Ont::RunFactory.new(attributes, run)
            factory.save
            new_flowcell_ids = run.flowcells.map(&:id)
            expect(run.flowcells.count).to eq(3)
            expect(new_flowcell_ids - initial_flowcell_ids).to match_array(new_flowcell_ids)

            expect(Ont::Flowcell.where(id: new_flowcell_ids).map(&:run))
              .to all(eq(run))

            expect(run.flowcells.first.position).to eq(1)
            expect(run.flowcells.first.library)
              .to eq(Ont::Library.find_by(name: libraries.first.name))
            expect(run.flowcells.second.position).to eq(2)
            expect(run.flowcells.second.library)
              .to eq(Ont::Library.find_by(name: libraries.second.name))
            expect(run.flowcells.third.position).to eq(3)
            expect(run.flowcells.third.library)
              .to eq(Ont::Library.find_by(name: libraries.third.name))
          end

          it 'destroys the old flowcells' do
            run.flowcells.each do |fc|
              expect(fc).to receive(:destroy)
            end
            factory = Ont::RunFactory.new([], run)
            factory.save
          end
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
            # TODO: Ideally we'd not validate any flow cells,
            #       but when the run saves, it validates them anyway.
            #       In addition, the same flowcell added more than once doesn't create more than
            #       one relationship with the run.
            expect(flowcell).to receive(:valid?).exactly(1)
            factory = Ont::RunFactory.new(attributes)
            factory.save(validate: false)
          end
        end
      end
    end

    context 'invalid build' do
      def set_up_invalid_run
        errors = ActiveModel::Errors.new(Ont::Run.new)
        errors.add('run', message: 'This is a test error')
        allow_any_instance_of(Ont::Run).to receive(:valid?).and_return(false)
        allow_any_instance_of(Ont::Run).to receive(:errors).and_return(errors)
      end

      before do |test|
        set_up_invalid_run unless test.metadata[:needs_valid_run]
      end

      it 'returns false on save' do
        factory = Ont::RunFactory.new([])
        expect(factory.save).to be_falsey
      end

      context 'with no existing run supplied' do
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

      context 'with existing run supplied' do
        let!(:run) { create(:ont_run) }

        it 'does not save the state of the original run', :needs_valid_run do
          expect(run).to_not receive(:save)

          set_up_invalid_run # After we created a valid one above

          factory = Ont::RunFactory.new([], run)
          factory.save
        end

        it 'does not destroy the original flowcells', :needs_valid_run do
          run.flowcells.each do |fc|
            expect(fc).to_not receive(:destroy)
          end

          set_up_invalid_run # After we created a valid one above

          factory = Ont::RunFactory.new([], run)
          factory.save
        end
      end
    end
  end
end
