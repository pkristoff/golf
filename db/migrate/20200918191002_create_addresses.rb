# frozen_string_literal: true

# create Address
#
class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state
      t.integer :zip_code

      t.timestamps
    end
    add_reference(:courses, :address, index: true)
    add_foreign_key(:courses, :addresses)
  end
end
