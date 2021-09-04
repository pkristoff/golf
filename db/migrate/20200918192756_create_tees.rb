# frozen_string_literal: true

# create Tee
#
class CreateTees < ActiveRecord::Migration[6.0]
  # change
  #
  def change
    create_table :tees do |t|
      t.string :color, default: 'White', null: false
      t.numeric :rating, default: 0.0, null: false
      t.numeric :slope, default: 0.0, null: false
      t.belongs_to :course, index: true

      t.timestamps
    end
    add_index 'tees', %i[color course_id], unique: true
  end
end
