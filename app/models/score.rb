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

  # figures out the golf term for this score
  #
  # === Returns:
  #
  # * <tt>:String</tt> Albatross ... Triple-Bogey
  #
  def golf_term
    Score.golf_term(hole.par, strokes)
  end

  # figures out the golf term for this score
  #
  # === Parameters:
  #
  # * <tt>:par</tt> par for this hole
  # * <tt>:strokes</tt> taken for this hole
  #
  # === Returns:
  #
  # * <tt>:String</tt> Albatross ... Triple-Bogey
  #
  def self.golf_term(par, strokes)
    case strokes - par
    when -3
      'Albatross'
    when -2
      'Eagle'
    when -1
      'Birdie'
    when 0
      'Par'
    when 1
      'Bogey'
    when 2
      'Double-bogey'
    else
      'Triple-bogey'
    end
  end
end
