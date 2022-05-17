# frozen_string_literal: true

shared_examples 'library' do
  it 'sets state to pending' do
    expect(create(library_factory).state).to eq('pending')
  end

  it 'is active' do
    expect(create(library_factory)).to be_active
  end

  context 'deactivate' do
    let(:library) { create(library_factory) }

    it 'can be deactivated' do
      expect(library.deactivate).to be_truthy
      expect(library.deactivated_at).to be_present
      expect(library).not_to be_active
    end

    it 'returns false if already deactivated' do
      library.deactivate
      expect(library.deactivate).to be_falsey
    end
  end

  context 'scope' do
    context 'active' do
      it 'returns only active libraries' do
        create_list(library_factory, 2)
        create(library_factory, deactivated_at: DateTime.now)
        expect(library_model.active.length).to eq 2
      end
    end
  end
end
