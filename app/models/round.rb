# frozen_string_literal: true

# Round
#
class Round < ApplicationRecord
  has_many(:score_holes, dependent: :destroy)
  belongs_to(:tee, validate: false)
  accepts_nested_attributes_for(:score_holes, allow_destroy: true)

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
    # rubocop:disable Layout/LineLength
    raise("score for hole number:#{hole.number} already exists") if score(hole.number)

    current_tee = score_holes.empty? ? nil : tee
    added_tee = hole.tee
    raise("Hole from a different tee current tee: '#{current_tee.color}' adding hole from tee '#{added_tee.color}'") if !current_tee.nil? && (current_tee.color != added_tee.color)

    current_course = current_tee.nil? ? nil : current_tee.course
    added_course = added_tee.course
    raise("Hole from a different course current course: '#{current_course.name}' adding hole from '#{added_course.name}'") unless current_tee.nil? || (current_course.name == added_course.name)

    # rubocop:enable Layout/LineLength

    penalties = '' if penalties.nil?
    score = Score.create(round: self, strokes: strokes, putts: putts, penalties: penalties)
    score_hole = ScoreHole.create(hole: hole, score: score)
    score_holes << score_hole
    # scores << score
    # score.round = self
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
    sh = score_holes.detect { |score_hole| score_hole.hole.number == hole_number }
    return sh if sh.nil?

    sh.score
  end

  # returns holes sorted by Hole.number
  #
  # === Returns:
  #
  # * <tt>Array</tt> holes sorted by Hole.number
  #
  def sorted_score_holes
    score_holes.sort_by { |score_hole| score_hole.hole.number }
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

  # return Score for next hole given a Score
  #   if initial Score is for last hole (9 or 18) then return
  #   Score associated with Hole.number 1.
  #
  # === Parameters:
  #
  # * <tt>:score</tt> The initial Score
  #
  # === Returns:
  #
  # * <tt>Score</tt> next Score
  #
  def next_score(score)
    ssh = sorted_score_holes
    max_holes = ssh.size
    index = ssh.find_index { |score_hole| score_hole.score == score }
    next_index = index + 1 unless index == max_holes
    next_index = 1 if index == max_holes
    return ssh[next_index].score unless ssh[next_index].nil?

    ssh[0].score
  end
end
