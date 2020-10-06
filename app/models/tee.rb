# frozen_string_literal: true

# Tee
#
class Tee < ApplicationRecord
  belongs_to(:course)

  has_many(:holes, dependent: :destroy)
  accepts_nested_attributes_for(:holes, allow_destroy: true)

  # Add 18 Holes numbered 1-18
  #
  def add_18_holes
    (1...19).each do |num|
      add_hole(num)
    end
  end

  # Add 9 Holes numbered 1-9
  #
  def add_9_holes
    (1...10).each do |num|
      add_hole(num)
    end
  end

  # Find the Hole with number hole_num
  #
  # === Parameters:
  #
  # * <tt>:hole_num</tt> common event
  #
  # === Returns:
  #
  # * <tt>Hole</tt>
  #
  def hole(hole_num)
    hole = holes.detect { |hle| hle.number == hole_num }
    raise("Hole not found:  #{hole_num}") if hole.nil?

    hole
  end

  private

  def add_hole(hole_number)
    hole = Hole.new(number: hole_number)
    hole.tee = self
    holes.push(hole)
  end
end
