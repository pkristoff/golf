# frozen_string_literal: true

# RoundInfoSpecHelper
#
module RoundInfoSpecHelper
  class << self

    def create_round18(slope, rating, today_offset, score_increase, score_info)
      round = FactoryBot.create(:round,
                                date: Time.zone.now.to_date - today_offset,
                                round_score_info: generate_round_scores( score_info, score_increase))
      round.tee.slope = slope
      round.tee.rating = rating
      round.tee.save!
      round
    end

    def create_round9(slope, rating, today_offset, score_increase, score_info)
      now = Time.zone.now
      round = FactoryBot.create(:round,
                                date: now.to_date - today_offset,
                                round_score_info: generate_round_scores(score_info, score_increase))

      tee = round.tee
      course = tee.course
      course.number_of_holes = 9
      course.update_number_of_holes
      tee.slope = slope
      tee.rating = rating
      course.save!
      tee.save!
      round
    end
  end

  def self.generate_round_scores(base, increase)
    gen_round = []
    base.map do |entry|
      gen_round.push([entry[0], entry[1] + increase, entry[2]]) unless entry[0].nil?
      gen_round.push([entry[0], entry[1] + (increase * 9), entry[2]]) if entry[0].nil? && (entry[1] < 70)
      gen_round.push([entry[0], entry[1] + (increase * 18), entry[2]]) if entry[0].nil? && entry[1] > 70
    end
    gen_round
  end
end

