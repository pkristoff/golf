# frozen_string_literal: true

# create Hole
#
class CreateHoles < ActiveRecord::Migration[6.0]
  def change
    create_table :holes do |t|
      t.integer :number
      t.integer :yardage
      t.integer :par
      t.integer :hdcp
      t.belongs_to :tee, index: true

      t.timestamps
    end
  end
end
