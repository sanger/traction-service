# frozen_string_literal: true

require Rails.root.join('lib', 'dependent_loader')

DependentLoader.start(:enzymes) do |on|
  on.success do
    Enzyme.create(
      [
        { name: 'Nb.BbvCI' },
        { name: 'Nb.BsmI' },
        { name: 'Nb.BsrDI' },
        { name: 'Nt.BspQI' },
        { name: 'Nb.BssSI' },
        { name: 'DLE-1' }
      ]
    )
  end
end
