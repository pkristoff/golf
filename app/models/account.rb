# frozen_string_literal: true

# Account
#
class Account < ApplicationRecord
  include DebugHelper
  validates :name, presence: true
  # calc_handicap_index
  #
  # === Parameters:
  #
  # * <tt>:ihix</tt> initial handicap_index
  #
  def calc_handicap_index(ihix = nil)
    rounds_18hole = Account.find_18_hole_rounds
    sorted_rounds = rounds_18hole.sort_by(&:date)
    # Round.print(sorted_rounds)
    initial_handicap_index = ihix unless ihix.nil?
    initial_handicap_index = (handicap_index == 0.0 ? 50 : handicap_index) if ihix.nil?
    hix, rounds, score_differentials, diffs_to_use, adjustment, avg, avg_adj, avg_adj96, sd_info =
      calc_handicap_index_for_rounds(sorted_rounds, initial_handicap_index)
    self.handicap_index = hix unless hix.nil?
    print_hi_info(initial_handicap_index, rounds, score_differentials, diffs_to_use, adjustment,
                  avg, avg_adj, avg_adj96, hix, sd_info)
    [hix, initial_handicap_index, rounds, score_differentials, diffs_to_use, adjustment, avg, avg_adj, avg_adj96, hix, sd_info]
  end

  # print debug info for calculating handicap index
  #
  # === Parameters:
  #
  # * <tt>:initial_handicap_index</tt> initial handicap_index
  # * <tt>:rounds</tt> the rounds to consider
  # * <tt>:score_differentials</tt> for each round
  # * <tt>:diffs_to_use</tt> the score_differentials to avg
  # * <tt>:adjustment</tt> the adjustment to avg
  # * <tt>:avg</tt> score_differentials avg
  # * <tt>:avg_adj</tt> score_differentials avg - adj
  # * <tt>:avg_adj96</tt> 96% of avg_adj
  # * <tt>:hix</tt> handicap index
  # * <tt>:sd_info</tt> info used to calc score_differential for eacch round
  #
  def print_hi_info(initial_handicap_index, rounds, score_differentials, diffs_to_use, adjustment,
                    avg, avg_adj, avg_adj96, hix, sd_info)
    xpp('CALCULATING', 'calc_handicap_index')
    xpp('initial_handicap_index', initial_handicap_index)
    xpp('diffs_to_use', diffs_to_use.size) unless rounds.empty?
    rounds.each_with_index do |rd, index|
      xpp('Course', rd.tee.course.name, 'rd.date', rd.date)
      xpp('  score_diff', format('%.1f', score_differentials[index]),
          'use', diffs_to_use.include?(score_differentials[index]))
      info = sd_info[index]
      xpp('  course_handicap', info[3], 'slope', info[4], 'rating', info[5])
      xpp('  tee_par', info[0], 'adjusted_score', info[1], 'gross_score', info[2])
      xpp('  avg', avg, 'adjustment', adjustment)
      xpp('  avg_adj', avg_adj, 'avg_adj96', avg_adj96)
      xpp('  hix', hix)
    end
  end

  # calculates handicap_index given an array of rounds
  # also sets the field handicap_index
  #
  # === Parameters:
  #
  # * <tt>:sorted_rounds</tt>
  # * <tt>:initial_handicap_index</tt> initial handicap_index
  #
  # === Returns:
  #
  # * <tt>:Number</tt> handicap_index
  #
  #
  def calc_handicap_index_for_rounds(sorted_rounds, initial_handicap_index)
    sd_info = []
    score_diffs = sorted_rounds.last(20).map do |round|
      tee_par, gross_score, unadjusted_score, sd, course_handicap, slope, rating =
        Account.calc_score_differential(round, initial_handicap_index)
      sd_info.push([tee_par, gross_score, unadjusted_score, course_handicap, slope, rating])
      sd
    end
    unless score_diffs.empty?
      hix, diffs_to_use, adjustments, avg, avg_adj, avg_adj96 =
        Tee.final_calc_handicap_index(score_diffs.sort)
    end
    [hix, sorted_rounds, score_diffs, diffs_to_use, adjustments, avg, avg_adj, avg_adj96].push(sd_info)
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
    # xpp('course_handicap', course_handicap, 'slope', slope, 'rating', rating)
    round.sorted_score_holes.each do |score_hole|
      hole_par = score_hole.hole.par
      adj_score = Tee.calc_adjusted_score(course_handicap, score_hole.score.strokes, hole_par)
      unadjusted_score += score_hole.score.strokes
      gross_score += adj_score
    end
    # xpp('par', tee_par, 'gross_score', gross_score, 'unadjusted_score', unadjusted_score)
    sd = Tee.calc_score_differential(gross_score, rating, slope)
    [tee_par, gross_score, unadjusted_score, sd, course_handicap, slope, rating]
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
