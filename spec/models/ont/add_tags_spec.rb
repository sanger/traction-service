require 'rails_helper'

RSpec.describe Ont::AddTags, type: :model, ont: true do

  let(:tag_set)       { create(:tag_set_with_tags, number_of_tags: 96) }
  let(:ordered_tags)  { tag_set.tags.order(:group_id) }

  def find_tag_for_well(plate, position)
    plate.wells.find_by(position: position).container_materials.first.material.tags.first
  end

  describe 'when there are no existing tags' do

    let(:plate) { create(:plate_with_wells_and_requests, column_count: 12, row_count: 8)}

    describe 'by column' do
      before(:each) do
        Ont::AddTags.run!(plate: plate, order: 'column', tag_set: tag_set)
      end

      it 'will add the tags in the correct order' do
        expect(find_tag_for_well(plate, "A1")).to eq(ordered_tags[0])
        expect(find_tag_for_well(plate, "B1")).to eq(ordered_tags[1])
        expect(find_tag_for_well(plate, "C1")).to eq(ordered_tags[2])
        expect(find_tag_for_well(plate, "D1")).to eq(ordered_tags[3])
        expect(find_tag_for_well(plate, "E1")).to eq(ordered_tags[4])
        expect(find_tag_for_well(plate, "F1")).to eq(ordered_tags[5])
        expect(find_tag_for_well(plate, "G1")).to eq(ordered_tags[6])
        expect(find_tag_for_well(plate, "H1")).to eq(ordered_tags[7])

        expect(find_tag_for_well(plate, "A12")).to eq(ordered_tags[88])
        expect(find_tag_for_well(plate, "B12")).to eq(ordered_tags[89])
        expect(find_tag_for_well(plate, "C12")).to eq(ordered_tags[90])
        expect(find_tag_for_well(plate, "D12")).to eq(ordered_tags[91])
        expect(find_tag_for_well(plate, "E12")).to eq(ordered_tags[92])
        expect(find_tag_for_well(plate, "F12")).to eq(ordered_tags[93])
        expect(find_tag_for_well(plate, "G12")).to eq(ordered_tags[94])
        expect(find_tag_for_well(plate, "H12")).to eq(ordered_tags[95])
      end
    end

    describe 'by row' do
      before(:each) do
        Ont::AddTags.run!(plate: plate, order: 'row', tag_set: tag_set)
      end

      it 'will add the tags in the correct order' do
        expect(find_tag_for_well(plate, "A1")).to eq(ordered_tags[0])
        expect(find_tag_for_well(plate, "A2")).to eq(ordered_tags[1])
        expect(find_tag_for_well(plate, "A3")).to eq(ordered_tags[2])
        expect(find_tag_for_well(plate, "A4")).to eq(ordered_tags[3])
        expect(find_tag_for_well(plate, "A5")).to eq(ordered_tags[4])
        expect(find_tag_for_well(plate, "A6")).to eq(ordered_tags[5])
        expect(find_tag_for_well(plate, "A7")).to eq(ordered_tags[6])
        expect(find_tag_for_well(plate, "A8")).to eq(ordered_tags[7])
        expect(find_tag_for_well(plate, "A9")).to eq(ordered_tags[8])
        expect(find_tag_for_well(plate, "A10")).to eq(ordered_tags[9])
        expect(find_tag_for_well(plate, "A11")).to eq(ordered_tags[10])
        expect(find_tag_for_well(plate, "A12")).to eq(ordered_tags[11])

        expect(find_tag_for_well(plate, "H1")).to eq(ordered_tags[84])
        expect(find_tag_for_well(plate, "H2")).to eq(ordered_tags[85])
        expect(find_tag_for_well(plate, "H3")).to eq(ordered_tags[86])
        expect(find_tag_for_well(plate, "H4")).to eq(ordered_tags[87])
        expect(find_tag_for_well(plate, "H5")).to eq(ordered_tags[88])
        expect(find_tag_for_well(plate, "H6")).to eq(ordered_tags[89])
        expect(find_tag_for_well(plate, "H7")).to eq(ordered_tags[90])
        expect(find_tag_for_well(plate, "H8")).to eq(ordered_tags[91])
        expect(find_tag_for_well(plate, "H9")).to eq(ordered_tags[92])
        expect(find_tag_for_well(plate, "H10")).to eq(ordered_tags[93])
        expect(find_tag_for_well(plate, "H11")).to eq(ordered_tags[94])
        expect(find_tag_for_well(plate, "H12")).to eq(ordered_tags[95])
      end
    end
    
  end

  describe 'when there are existing tags' do

    let(:plate)         { create(:plate_with_tagged_ont_requests, column_count: 12, row_count: 8)}

    describe 'by row' do

      before(:each) do
        Ont::AddTags.run!(plate: plate, order: 'row', tag_set: tag_set)
        Ont::AddTags.run!(plate: plate, order: 'column', tag_set: tag_set)
      end

      it 'reassigns the tags correctly' do
        expect(find_tag_for_well(plate, "A1")).to eq(ordered_tags[0])
        expect(find_tag_for_well(plate, "B1")).to eq(ordered_tags[1])
        expect(find_tag_for_well(plate, "C1")).to eq(ordered_tags[2])
        expect(find_tag_for_well(plate, "D1")).to eq(ordered_tags[3])
        expect(find_tag_for_well(plate, "E1")).to eq(ordered_tags[4])
        expect(find_tag_for_well(plate, "F1")).to eq(ordered_tags[5])
        expect(find_tag_for_well(plate, "G1")).to eq(ordered_tags[6])
        expect(find_tag_for_well(plate, "H1")).to eq(ordered_tags[7])

        expect(find_tag_for_well(plate, "A12")).to eq(ordered_tags[88])
        expect(find_tag_for_well(plate, "B12")).to eq(ordered_tags[89])
        expect(find_tag_for_well(plate, "C12")).to eq(ordered_tags[90])
        expect(find_tag_for_well(plate, "D12")).to eq(ordered_tags[91])
        expect(find_tag_for_well(plate, "E12")).to eq(ordered_tags[92])
        expect(find_tag_for_well(plate, "F12")).to eq(ordered_tags[93])
        expect(find_tag_for_well(plate, "G12")).to eq(ordered_tags[94])
        expect(find_tag_for_well(plate, "H12")).to eq(ordered_tags[95])
      end
    end

    describe 'by column' do

      before(:each) do
        Ont::AddTags.run!(plate: plate, order: 'column', tag_set: tag_set)
        Ont::AddTags.run!(plate: plate, order: 'row', tag_set: tag_set)
      end

      it 'reassigns the tags correctly' do
        expect(find_tag_for_well(plate, "A1")).to eq(ordered_tags[0])
        expect(find_tag_for_well(plate, "A2")).to eq(ordered_tags[1])
        expect(find_tag_for_well(plate, "A3")).to eq(ordered_tags[2])
        expect(find_tag_for_well(plate, "A4")).to eq(ordered_tags[3])
        expect(find_tag_for_well(plate, "A5")).to eq(ordered_tags[4])
        expect(find_tag_for_well(plate, "A6")).to eq(ordered_tags[5])
        expect(find_tag_for_well(plate, "A7")).to eq(ordered_tags[6])
        expect(find_tag_for_well(plate, "A8")).to eq(ordered_tags[7])
        expect(find_tag_for_well(plate, "A9")).to eq(ordered_tags[8])
        expect(find_tag_for_well(plate, "A10")).to eq(ordered_tags[9])
        expect(find_tag_for_well(plate, "A11")).to eq(ordered_tags[10])
        expect(find_tag_for_well(plate, "A12")).to eq(ordered_tags[11])

        expect(find_tag_for_well(plate, "H1")).to eq(ordered_tags[84])
        expect(find_tag_for_well(plate, "H2")).to eq(ordered_tags[85])
        expect(find_tag_for_well(plate, "H3")).to eq(ordered_tags[86])
        expect(find_tag_for_well(plate, "H4")).to eq(ordered_tags[87])
        expect(find_tag_for_well(plate, "H5")).to eq(ordered_tags[88])
        expect(find_tag_for_well(plate, "H6")).to eq(ordered_tags[89])
        expect(find_tag_for_well(plate, "H7")).to eq(ordered_tags[90])
        expect(find_tag_for_well(plate, "H8")).to eq(ordered_tags[91])
        expect(find_tag_for_well(plate, "H9")).to eq(ordered_tags[92])
        expect(find_tag_for_well(plate, "H10")).to eq(ordered_tags[93])
        expect(find_tag_for_well(plate, "H11")).to eq(ordered_tags[94])
        expect(find_tag_for_well(plate, "H12")).to eq(ordered_tags[95])
      end
    end
  end

end