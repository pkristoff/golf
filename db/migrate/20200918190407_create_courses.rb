# frozen_string_literal: true

# create Course
#
class CreateCourses < ActiveRecord::Migration[6.0]
  def change
    create_table :courses do |t|
      t.string :name, default: '', null: false
      t.timestamps
    end
    add_index 'courses', ['name'], unique: true
  end
end
