# frozen_string_literal: true

# create accounts
#
class CreateAccounts < ActiveRecord::Migration[6.0]
  # change
  #
  def change
    create_table :accounts do |t|
      t.string :name, default: 'Paul', null: false
      t.numeric :handicap_index, default: 0.0, null: false

      t.timestamps
    end
    add_column :tees, :course_index, :numeric, default: 0.0, null: false
  end
end
