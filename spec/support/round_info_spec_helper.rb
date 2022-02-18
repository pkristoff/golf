# frozen_string_literal: true

# RoundInfoSpecHelper
#
module RoundInfoSpecHelper
  ROUND_SCORE_INFO_BLACK18 = [
    # [hole, strokes, putts, penalties, Fairways, strokes inside 80]
    [1, 4, 2],
    [2, 4, 2],
    [3, 3, 2],
    [4, 4, 2],
    [5, 4, 2],
    [6, 4, 2],
    [7, 3, 2],
    [8, 4, 2],
    [9, 5, 2],
    [nil, 35, 18],
    [10, 4, 2],
    [11, 3, 2],
    [12, 5, 2],
    [13, 4, 2],
    [14, 4, 2],
    [15, 4, 2],
    [16, 5, 2],
    [17, 3, 2],
    [18, 4, 2],
    [nil, 36, 18],
    [nil, 71, 36]
  ].freeze
  ROUND_SCORE_INFO_BLACK9 = [
    # [hole, strokes, putts]
    # 0..9
    [1, 6, 2], # 4
    [2, 6, 2], # 4
    [3, 5, 2], # 3
    # 10..19
    [4, 8, 2], # 4
    [5, 8, 2], # 4
    [6, 8, 2], # 4
    # 20..29
    [7, 9, 2], # 3
    [8, 9, 2], # 4
    [9, 9, 2], # 5

    [nil, 68, 18],

    # 30..39
    [10, 10, 2], # 4
    [11, 10, 2], # 3
    [12, 10, 2], # 5
    # else
    [13, 11, 2], # 4
    [14, 4, 2], # 4
    [15, 4, 2], # 4
    [16, 5, 2], # 5
    [17, 3, 2], # 3
    [18, 4, 2], # 4
    [nil, 61, 18],
    [nil, 129, 36]
  ].freeze
  class << self
    # check totals for tee if problem raise signal
    #
    # === Parameters:
    #
    # * <tt>:slope</tt>
    # * <tt>:rating</tt>
    # * <tt>:today_offset</tt>
    # * <tt>:score_increase</tt>
    # * <tt>:score_info</tt>
    #
    # === Returns:
    #
    # * <tt>Round</tt>18 hole
    #
    def create_round18(slope, rating, today_offset, score_increase, score_info)
      round = FactoryBot.create(:round,
                                date: Time.zone.now.to_date - today_offset,
                                round_score_info: generate_round_scores(score_info, score_increase))
      round.tee.slope = slope
      round.tee.rating = rating
      round.tee.save!
      round
    end

    # creates 18 hole roune and then adjusts to 9 holes.
    #
    # === Parameters:
    #
    # * <tt>:slope</tt>
    # * <tt>:rating</tt>
    # * <tt>:today_offset</tt>
    # * <tt>:score_increase</tt>
    # * <tt>:score_info</tt>
    #
    # === Returns:
    #
    # * <tt>Round</tt>9 hole round
    #
    def create_round9(slope, rating, today_offset, score_increase, score_info)
      now = Time.zone.now
      round = FactoryBot.create(:round,
                                date: now.to_date - today_offset,
                                round_score_info: generate_round_scores(score_info, score_increase))

      tee = round.tee
      course = tee.course
      course.number_of_holes = 9
      course.update_number_of_holes
      round.adjust_number_of_holes
      tee.slope = slope
      tee.rating = rating
      course.save!
      tee.save!
      round.save!
      round
    end
  end

  # generate a new score_info with an increased score.
  #
  # === Parameters:
  #
  # * <tt>:base_score_info</tt>
  # * <tt>:increase_score_by</tt>
  #
  # === Returns:
  #
  # * <tt>Array</tt>new score_info
  #
  def self.generate_round_scores(base_score_info, increase_score_by)
    gen_round = []
    base_score_info.map do |entry|
      gen_round.push([entry[0], entry[1] + increase_score_by, entry[2]]) unless entry[0].nil?
      gen_round.push([entry[0], entry[1] + (increase_score_by * 9), entry[2]]) if entry[0].nil? && (entry[1] < 70)
      gen_round.push([entry[0], entry[1] + (increase_score_by * 18), entry[2]]) if entry[0].nil? && entry[1] > 70
    end
    gen_round
  end
end
