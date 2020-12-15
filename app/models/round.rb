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
  # * <tt>:putts</tt> for hole
  # * <tt>:penalties</tt> for hole
  #
  # === Returns:
  #
  # * <tt>Score</tt> added score for hole
  #
  def add_score(hole, strokes, putts, penalties)
    penalties = '' if penalties.nil?
    score = Score.new(hole_number: hole.number, strokes: strokes, putts: putts, penalties: penalties)
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

  # return Rounds with for a given course
  #
  # === Parameters:
  #
  # * <tt>:course</tt>
  #
  # === Returns:
  #
  # * <tt>Array</tt> of Round
  #
  def self.rounds(course)
    Round.all.select do |round|
      round.course.name == course.name
    end
  end
end
