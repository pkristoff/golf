# frozen_string_literal: true

# create Address
#
class CreateAddresses < ActiveRecord::Migration[6.0]
  # change
  #
  def change
    create_table :addresses do |t|
      t.string :street1, default: '', null: false
      t.string :street2, default: '', null: false
      t.string :city, default: '', null: false
      t.string :state, default: '', null: false
      t.string :zip_code, default: '27502', null: false

      t.timestamps
    end
    add_reference(:courses, :address, index: true)
    add_foreign_key(:courses, :addresses)
  end
end
