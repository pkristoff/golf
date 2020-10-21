# frozen_string_literal: true

# create Hole
#
class CreateHoles < ActiveRecord::Migration[6.0]
  def change
    create_table :holes do |t|
      t.integer :number, default: 0, null: false
      t.integer :yardage, default: 0, null: false
      t.integer :par, default: 0, null: false
      t.integer :hdcp, default: 0, null: false
      t.belongs_to :tee, index: true

      t.timestamps
    end
  end
end
