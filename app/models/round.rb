# frozen_string_literal: true

# Round
#
class Round < ApplicationRecord
  include DebugHelper
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
    score.calculate_green_in_regulation(hole)
    score.save
    score
  end

  # The number of holes for the course has been changed
  # so need to adjust the holes.
  #
  def adjust_number_of_holes
    num_of_holes = tee.course.number_of_holes
    number_of_holes = score_holes.size
    return if num_of_holes == number_of_holes

    add_back_nine if num_of_holes == 18 && number_of_holes == 9
    remove_back_nine if num_of_holes == 9 && number_of_holes == 18
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
    course_rounds = Round.all.select do |round|
      round.course.name == course.name
    end
    course_rounds.sort_by(&:date)
  end

  # prints round date and score differential - debug
  #
  # === Parameters:
  #
  # * <tt>:rounds</tt>
  #
  def self.print(rounds)
    rounds.each do |rd|
      score_differential = Account.calc_score_differential(rd, 50)
      xpp('Date', rd.date, 'score_diff', score_differential)
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
    score_hole = score_hole(score)
    hole_number = score_hole.hole.number
    max_holes = tee.course.number_of_holes
    next_hole_number = 1
    next_hole_number = hole_number + 1 unless hole_number == max_holes
    score(next_hole_number)
  end

  # return Hole associated with the Score
  #
  # === Parameters:
  #
  # * <tt>:score</tt> The Score
  #
  # === Returns:
  #
  # * <tt>Hole</tt> associated with the Score
  #
  def hole(score)
    score_hole = score_holes.detect { |score_hole_assoc| score_hole_assoc.score == score }
    return nil if score_hole.nil?

    score_hole.hole
  end

  private

  def score_hole(score)
    score_holes.detect { |score_hole| score == score_hole.score }
  end

  def remove_back_nine
    sorted = sorted_score_holes
    self.score_holes = sorted[0..8]
    sorted[9..sorted.size - 1].each(&:delete)
  end
end
