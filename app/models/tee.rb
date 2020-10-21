# frozen_string_literal: true

# Tee
#
class Tee < ApplicationRecord
  belongs_to(:course)

  has_many(:holes, dependent: :destroy)

  # Add a hole to tee
  #
  # === Parameters:
  #
  # * <tt>:hole_number</tt> golf course hole number
  # * <tt>:yardage</tt> for tee and hole number
  # * <tt>:par</tt> for tee and hole number
  # * <tt>:hdcp</tt> handicap for tee and hole number
  #
  # === Returns:
  #
  # * <tt>Hole</tt>
  #
  def add_hole(hole_number, yardage, par, hdcp)
    hole = Hole.new(number: hole_number, yardage: yardage, par: par, hdcp: hdcp)
    hole.tee = self
    holes.push(hole)
    hole
  end

  # Add 18 Holes numbered 1-18
  #
  def add_18_holes
    (1...19).each do |num|
      add_hole(num, nil, nil, nil)
    end
  end

  # Add 9 Holes numbered 1-9
  #
  def add_9_holes
    (1...10).each do |num|
      add_hole(num, nil, nil, nil)
    end
  end

  # Find the Hole with number hole_num
  #
  # === Parameters:
  #
  # * <tt>:hole_num</tt> golf course hole number
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
end
