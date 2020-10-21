# frozen_string_literal: true

# Create Round which is the Score for each hole.
#
class CreateRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :rounds do |t|
      t.date :date, default: Time.zone.today, null: false

      t.timestamps
    end
  end
end
