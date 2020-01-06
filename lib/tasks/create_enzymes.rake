# frozen_string_literal: true

namespace :enzymes do
  task create: :environment do
    Saphyr::Enzyme.create!(
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

  task destroy: :environment do
    Saphyr::Enzyme.delete_all
  end
end
