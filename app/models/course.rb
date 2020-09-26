class Course < ApplicationRecord

  belongs_to(:address, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:tees, dependent: :destroy)
  accepts_nested_attributes_for(:tees, allow_destroy: true)

  after_initialize :build_associations, if: :new_record?

  def build_associations
    address || build_address
    true
  end

  def add_tee (color, rating, slope, num_of_holes)
    tee = Tee.new(color: color, rating: rating, slope: slope)
    tee.course = self
    tee.add_18_holes
    tees.push(tee)
  end

  def tee(color)
    idx = tees.index{|x| x.color == color}
    return nil if idx.nil?
    tees[idx]
  end

end
