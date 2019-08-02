class ModifyMovieTimeColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :pacbio_wells, :movie_time, :decimal, precision: 3, scale: 1
  end
end
