RSpec.shared_examples "container" do
  let(:factory) { described_class.to_s.downcase.to_sym}

  it "returns empty materials for no container materials" do
    container = create(factory, container_materials: [])
    expect(container.materials).to be_empty
  end

  it 'returns all materials for some container materials' do
    container = create(factory)
    num_materials = 3
    container_materials = create_list(:container_material, num_materials, container: container)
    expect(container.materials.count).to eq(num_materials)
    expect(container.materials).to eq(container_materials.map { |con_mat| con_mat.material })
  end
end
