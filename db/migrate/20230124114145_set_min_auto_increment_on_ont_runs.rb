class SetMinAutoIncrementOnOntRuns < ActiveRecord::Migration[7.0]
  # Set minimum id for new ONT runs to 100
  # This migration is for MySQL only and we don't need to compute the min of 
  # 100 and the max value of existing records.
  #
  # https://dev.mysql.com/doc/refman/8.0/en/alter-table.html
  # You cannot reset the counter to a value less than or equal to the value 
  # that is currently in use. For both InnoDB and MyISAM, if the value is less
  # than or equal to the maximum value currently in the AUTO_INCREMENT column, 
  # the value is reset to the current maximum AUTO_INCREMENT column value plus 
  # one.
  def up
    ActiveRecord::Base.connection.execute('ALTER TABLE ont_runs AUTO_INCREMENT = 100')
  end

  def down
    # We do not have any previous resets; the default is 1
    ActiveRecord::Base.connection.execute('ALTER TABLE ont_runs AUTO_INCREMENT = 1')
  end
end
