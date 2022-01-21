# frozen_string_literal: true

# Account
#
class Account < ApplicationRecord
  include DebugHelper
  validates :name, presence: true
  # calc_handicap_index
  #
  def calc_handicap_index
    rounds_18hole = Account.find_18_hole_rounds
    sorted_rounds = rounds_18hole.sort_by(&:date)
    # Round.print(sorted_rounds)
    score_diffs = sorted_rounds.last(20).map do |round|
      # handicap_indeX should be course_handicap
      xpp('handicap_index', handicap_index)
      sd = Account.calc_score_differential(round, handicap_index == 0.0 ? 50 : handicap_index)
      xpp('handicap_index', handicap_index)
      xpp('  Course', round.tee.course.name, 'round.date', round.date, 'score_diff', sd)
      sd
    end
    xpp('date sorted score_diffs', score_diffs.map { |sd| format('%.1f', sd) })
    xpp('sccore sorted score_diffs', score_diffs.sort.map { |sd| format('%.1f', sd) })
    self.handicap_index = Tee.final_calc_handicap_index(score_diffs.sort) unless score_diffs.empty?
  end

  # find all rounds with played on 18 hole course
  #
  # === Returns:
  #
  # * <tt>:Array</tt> rounds
  #
  def self.find_18_hole_rounds
    rounds_18hole = []
    Round.find_each do |round|
      rounds_18hole.push(round) if round.tee.course.number_of_holes == 18
    end
    rounds_18hole
  end

  # calculate score differential
  #
  # === Parameters:
  #
  # * <tt>:round</tt>
  # * <tt>:handicap_index</tt>
  #
  def self.calc_score_differential(round, handicap_index)
    gross_score = 0
    unadjusted_score = 0
    tee = round.tee
    tee_par = tee.total_par
    rating = tee.rating
    slope = tee.slope
    course_handicap = Tee.calc_course_handicap(handicap_index, slope, rating, tee_par)
    xpp('course_handicap', course_handicap, 'slope', slope, 'rating', rating)
    round.sorted_score_holes.each do |score_hole|
      hole_par = score_hole.hole.par
      adj_score = Tee.calc_adjusted_score(course_handicap, score_hole.score.strokes, hole_par)
      # tee_par += score_hole.hole.par
      unadjusted_score += score_hole.score.strokes
      gross_score += adj_score
    end
    xpp('par', tee_par, 'gross_score', gross_score, 'unadjusted_score', unadjusted_score)
    Tee.calc_score_differential(gross_score, rating, slope)
  end

  # legal attributes for Course
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def self.basic_permitted_params
    %i[name id]
  end
end
