# frozen_string_literal: true

# create Tee
#
class CreateTees < ActiveRecord::Migration[6.0]
  def change
    create_table :tees do |t|
      t.string :color, default: 'White', null: false
      t.numeric :rating, default: '', null: false
      t.numeric :slope, default: '', null: false
      t.belongs_to :course, index: true

      t.timestamps
    end
  end
end
