namespace :enzymes do
  desc "TODO"
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

end
