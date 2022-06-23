# frozen_string_literal: true

# In order to keep track of what came from where, we link our requests to
# a reception
class AddReceptionIdToRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :requests, :reception, foreign_key: true, index: true
  end
end
