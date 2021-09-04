# frozen_string_literal: true

# Create Score
#
class CreateScores < ActiveRecord::Migration[6.0]
  # change
  #
  def change
    create_table :scores do |t|
      t.integer :strokes, default: 0, null: false
      t.integer :putts, default: 0, null: false
      t.string :penalties, default: '', null: false
      t.boolean :green_in_regulation, default: false, null: true
      t.boolean :fairway_hit, default: false, null: true
      t.integer :strokes_under80, default: -1, null: false
      t.belongs_to :round, index: true

      t.timestamps
    end
    create_table :score_holes do |t|
      t.belongs_to :score, index: true
      t.belongs_to :hole, index: true
      t.belongs_to :round, index: true

      t.timestamps null: false
    end
  end
end
