class CreateTees < ActiveRecord::Migration[6.0]
  def change
    create_table :tees do |t|
      t.string :color
      t.numeric :rating
      t.numeric :slope
      t.belongs_to :course, index: true

      t.timestamps
    end
  end
end
