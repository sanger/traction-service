class ChangePacbioRunCommentsLimit < ActiveRecord::Migration[7.0]
  def up
    # MySQL tries to convert existing column values to the new type as well as possible.
    # https://dev.mysql.com/doc/refman/8.0/en/alter-table.html
    change_column :pacbio_runs, :comments, :text
  end

  def down
    change_column :pacbio_runs, :comments, :string
  end
end
