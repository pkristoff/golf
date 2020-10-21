# frozen_string_literal: true

# Create Score
#
class CreateScores < ActiveRecord::Migration[6.0]
  def change
    create_table :scores do |t|
      t.integer :hole_number, default: 0, null: false
      t.integer :strokes, default: 0, null: false
      t.integer :putts, default: 0, null: false
      t.belongs_to :round, index: true

      t.timestamps
    end
    create_table :score_holes do |t|
      t.belongs_to :score, index: true
      t.belongs_to :hole, index: true

      t.timestamps null: false
    end
  end
end
