# frozen_string_literal: true

# Create Score
#
class Score < ApplicationRecord
  belongs_to :round, optional: true

  has_one :score_hole, dependent: :destroy
  has_one :hole, through: :score_hole
  accepts_nested_attributes_for :hole, allow_destroy: false

  # Sets green_in_regulation based on formula
  #
  # === Parameters:
  #
  # * <tt>:hole</tt> html
  #
  def calculate_green_in_regulation(hole)
    self.green_in_regulation = strokes - putts + 2 <= hole.par
  end
end
