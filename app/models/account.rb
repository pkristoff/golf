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
    rounds9holes = Account.find_9_hole_rounds_with_matching9
    sorted_round_info = rounds_18hole.concat(rounds9holes).sort_by(&:date)
    # Round.print(sorted_rounds)
    initial_handicap_index = ihix unless ihix.nil?
    initial_handicap_index = (handicap_index == 0.0 ? 50 : handicap_index) if ihix.nil?
    hix, sorted_round_info_last, initial_handicap_index,
      score_differentials, diffs_to_use,
      adjustment, avg, avg_adj, avg_adj96 =
      calc_handicap_index_for_rounds(sorted_round_info, initial_handicap_index)

    max_hix = nil
    max_hix = [hix, 54].min unless hix.nil?
    self.handicap_index = max_hix unless hix.nil?

    print_hi_info(initial_handicap_index, sorted_round_info_last, diffs_to_use, adjustment, avg, avg_adj, avg_adj96, hix)

    [hix, sorted_round_info_last, initial_handicap_index, sorted_round_info, score_differentials, diffs_to_use, adjustment,
     avg, avg_adj, avg_adj96, max_hix]
  end

  # print debug info for calculating handicap index
  #
  # === Parameters:
  #
  # * <tt>:initial_handicap_index</tt> initial handicap_index
  # * <tt>:sorted_round_info</tt> the rounds to consider
  # * <tt>:diffs_to_use</tt> the score_differentials to avg
  # * <tt>:adjustment</tt> the adjustment to avg
  # * <tt>:avg</tt> score_differentials avg
  # * <tt>:avg_adj</tt> score_differentials avg - adj
  # * <tt>:avg_adj96</tt> 96% of avg_adj
  # * <tt>:hix</tt> handicap index
  #
  def print_hi_info(initial_handicap_index, sorted_round_info, diffs_to_use, adjustment,
                    avg, avg_adj, avg_adj96, hix)
    xpp('CALCULATING', 'calc_handicap_index')
    xpp('initial_handicap_index', initial_handicap_index)
    xpp('diffs_to_use', diffs_to_use.size) unless sorted_round_info.empty?
    sorted_round_info.each do |round_info|
      xpp('start =================== ', round_info.number_of_holes)
      round_info.print_hi_info(diffs_to_use)
      xpp('end =================== ', round_info.number_of_holes)
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
  # * <tt>:sorted_round_info</tt>
  # * <tt>:initial_handicap_index</tt> initial handicap_index
  #
  # === Returns:
  #
  # * <tt>:Number</tt> handicap_index
  #
  #
  def calc_handicap_index_for_rounds(sorted_round_info, initial_handicap_index)
    sorted_round_info_last = sorted_round_info.last(20)
    score_diffs = sorted_round_info_last.map do |round_info|
      total_score_differential =
        round_info.calc_score_differential(initial_handicap_index)
      total_score_differential
    end
    unless score_diffs.empty?
      hix, diffs_to_use, adjustments, avg, avg_adj, avg_adj96 =
        Tee.final_calc_handicap_index(score_diffs.sort)
    end
    [hix, sorted_round_info_last, initial_handicap_index, score_diffs, diffs_to_use, adjustments, avg, avg_adj, avg_adj96]
  end

  # find all rounds with played on 18 hole course
  #
  # === Returns:
  #
  # * <tt>:Array</tt> rounds
  #
  def self.find_all_rounds
    Account.find_18_hole_rounds.concat(Account.find_9_hole_rounds_with_matching9)
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
      rounds_18hole.push(RoundInfo.new(round, 18)) if round.tee.course.number_of_holes == 18
    end
    rounds_18hole
  end

  # find all 9 hole rounds where two rounds played on same date.
  #
  # === Returns:
  #
  # * <tt>:Array</tt> rounds
  #
  def self.find_9_hole_rounds_with_matching9
    rounds_9hole = []
    Round.find_each do |round|
      rounds_9hole.push(round) if round.tee.course.number_of_holes == 9
    end
    exclude_rounds = []
    matching_9hole = []
    rounds_9hole.each do |rd|
      next unless matching_9hole.select { |round_info| round_info.includes?(rd) }.empty?

      next if exclude_rounds.include?(rd)

      rd_date = rd.date
      date_rounds = rounds_9hole.select { |rd2| rd2.date == rd_date }
      matching_9hole.push(RoundInfo9.new(date_rounds.first, date_rounds.second, 9)) if date_rounds.size >= 2
      exclude_rounds.concat(date_rounds.last(date_rounds.size - 2)) if date_rounds.size >= 2
    end
    matching_9hole
  end

  # calculate score differential
  #
  # === Parameters:
  #
  # * <tt>:round_info</tt>
  # * <tt>:handicap_index</tt>
  #
  def self.calc_score_differential(round_info, handicap_index)
    gross_score = 0
    unadjusted_score = 0
    tee = round_info.tee
    tee_par = tee.total_par
    rating = tee.rating
    slope = tee.slope
    course_handicap = Tee.calc_course_handicap(handicap_index, slope, rating, tee_par)
    # xpp('course_handicap', course_handicap, 'slope', slope, 'rating', rating)
    round_info.sorted_score_holes.each do |score_hole|
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
