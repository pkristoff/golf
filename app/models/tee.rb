class Tee < ApplicationRecord
  belongs_to(:course)

  # belongs_to(:address, validate: false, dependent: :destroy)
  # accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:holes, dependent: :destroy)
  accepts_nested_attributes_for(:holes, allow_destroy: true)

  def add_18_holes
    (1...19).each do |num|
      add_hole(num)
    end
  end

  def add_9_holes
    (1...10).each do |num|
      add_hole(num)
    end
  end

  private

  def add_hole(hole_number)
    hole = Hole.new(number: hole_number)
    hole.tee = self
    holes.push(hole)
  end
end
