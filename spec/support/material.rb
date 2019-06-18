shared_examples "material" do
  it { is_expected.to have_one(:tube) }
end
