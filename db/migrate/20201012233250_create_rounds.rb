# frozen_string_literal: true

# Create Round which is the Score for each hole.
#
class CreateRounds < ActiveRecord::Migration[6.0]
  # change
  #
  def change
    create_table :rounds do |t|
      t.date :date, default: Time.zone.today, null: false
      t.numeric :handicap, default: 0.0, null: false
      t.belongs_to :tee, index: true

      t.timestamps
    end
  end
end
