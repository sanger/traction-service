# frozen_string_literal: true

# Rubocop want us to add a uniqueness constraint to the database. In practice
# we're unlikely to reap much form the performance or data-integrity issues,
# this will be a low volume rarely changing table, but there could be risks
# of concurrency problems running tasks on deployment.
class AddUniquenessContrataintToDataTypeName < ActiveRecord::Migration[7.0]
  def change
    add_index :data_types, %i[pipeline name], unique: true
  end
end
