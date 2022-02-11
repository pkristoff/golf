# frozen_string_literal: true

# RoundInfoSpecHelper
#
module RoundInfoSpecHelper
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
