# frozen_string_literal: true

RSpec.shared_examples 'tube_material' do
  it_behaves_like 'material'

  it { is_expected.to respond_to(:tube) }

  it 'accesses the correct tube' do
    material = create(material_model)
    tube = create(:tube)
    create(:container_material, container: tube, material:)

    # Sanity check using .container
    expect(material.container).to eq(tube)

    # and .tube is also the original tube
    expect(material.tube).to eq(tube)
  end

  it 'gets back nil for the tube if it is in a well' do
    material = create(material_model)
    well = create(:well)
    create(:container_material, container: well, material:)

    # Sanity check using .container
    expect(material.container).to eq(well)

    # but .tube is nil
    expect(material.tube).to be_nil
  end
end
