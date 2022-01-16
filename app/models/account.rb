# frozen_string_literal: true

# Account
#
class Account < ApplicationRecord
  include DebugHelper
  # calc_handicap_index
  #
  def calc_handicap_index
    rounds_18hole = []
    Round.find_each do |round|
      rounds_18hole.push(round) if round.tee.course.number_of_holes == 18
    end
    sorted_rounds = rounds_18hole.sort_by(&:date)
    # Round.print(sorted_rounds)
    score_diffs = sorted_rounds.map do |round|
      # handicap_indeX should be course_handicap
      xpp('handicap_index', handicap_index)
      sd = Account.calc_score_differential(round, handicap_index == 0.0 ? 50 : handicap_index)
      xpp('handicap_index', handicap_index)
      xpp('  date', round.date, 'score_diff', sd)
      sd
    end
    xpp('date sorted score_diffs', score_diffs.map { |sd| format('%.1f', sd) })
    xpp('sccore sorted score_diffs', score_diffs.sort.map { |sd| format('%.1f', sd) })
    self.handicap_index = Tee.calc_handicap_index(score_diffs.sort) unless score_diffs.empty?
  end

  # calculate score differential
  #
  # === Parameters:
  #
  # * <tt>:round</tt>
  # * <tt>:course_handicap</tt>
  #
  def self.calc_score_differential(round, course_handicap)
    gross_score = 0
    unadjusted_score = 0
    tee_par = 0
    round.sorted_score_holes.each do |score_hole|
      adj_score = Tee.calc_adjusted_score(course_handicap, score_hole.score.strokes, score_hole.hole.par)
      tee_par += score_hole.hole.par
      unadjusted_score += score_hole.score.strokes
      gross_score += adj_score
    end
    xpp('par', tee_par, 'gross_score', gross_score, 'unadjusted_score', unadjusted_score)
    rating = round.tee.rating
    slope = round.tee.slope
    Tee.calc_score_differential(gross_score, rating, slope)
  end
end
