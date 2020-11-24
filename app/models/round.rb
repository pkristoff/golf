# frozen_string_literal: true

# Round
#
class Round < ApplicationRecord
  has_many(:scores, dependent: :destroy)
  accepts_nested_attributes_for(:scores, allow_destroy: true)

  # Tee for round
  #
  # === Returns:
  #
  # * <tt>Tee</tt>
  #
  def tee
    scores.first.hole.tee
  end

  # Course the round was played on
  #
  # === Returns:
  #
  # * <tt>Course</tt>
  #
  delegate :course, to: :tee

  # Add Score for Hole
  #
  # === Parameters:
  #
  # * <tt>:hole</tt> hole
  # * <tt>:strokes</tt> for hole
  # * <tt>:putts</tt> dor hole
  #
  # === Returns:
  #
  # * <tt>Score</tt> added score for hole
  #
  def add_score(hole, strokes, putts)
    score = Score.new(hole_number: hole.number, strokes: strokes, putts: putts)
    score.hole = hole
    scores << score
    score.round = self
    score
  end

  # return Score for hole_number
  #
  # === Parameters:
  #
  # * <tt>:hole_number</tt> hole number for Score
  #
  # === Returns:
  #
  # * <tt>Score</tt>
  #
  def score(hole_number)
    scores.detect { |score| score.hole.number == hole_number }
  end
end
