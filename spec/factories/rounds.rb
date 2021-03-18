# frozen_string_literal: true

require 'support/tee_hole_info'

FactoryBot.define do
  factory :round do
    date { Time.zone.today }
    tee do
      course = FactoryBot.create(:course, name: 'prk')
      course.tee('Black')
    end
    after(:create) do |round, _evaluator|
      tee = round.tee
      nine_stroke_total = nil
      nine_putt_total = nil
      eighteen_stroke_total = nil
      eighteen_putt_total = nil
      total_stroke_total = nil
      total_putt_total = nil
      TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO].each do |score_info|
        hole_number = score_info[0]
        strokes = score_info[1]
        putts = score_info[2]
        if hole_number.nil?
          total_stroke_total = strokes if !nine_stroke_total.nil? && !eighteen_stroke_total.nil? && total_stroke_total.nil?
          eighteen_stroke_total = strokes if !nine_stroke_total.nil? && eighteen_stroke_total.nil?
          nine_stroke_total = strokes if nine_stroke_total.nil?

          total_putt_total = putts if !nine_putt_total.nil? && !eighteen_putt_total.nil? && total_putt_total.nil?
          eighteen_putt_total = putts if !nine_putt_total.nil? && eighteen_putt_total.nil?
          nine_putt_total = putts if nine_putt_total.nil?
        else
          hole = tee.hole(hole_number)
          round.add_score(hole, strokes, putts, '')
        end
      end
      check_totals(round, nine_stroke_total, nine_putt_total,
                   eighteen_stroke_total, eighteen_putt_total,
                   total_stroke_total, total_putt_total)
    end
  end
end

def check_totals(round, front_nine_strokes, front_nine_putts,
                 back_nine_strokes, back_nine_putts,
                 stroke_total, putt_total)
  sum_strokes = 0
  sum_putts = 0
  (1..9).each do |hole_number|
    score = round.score(hole_number)
    sum_strokes += score.strokes
    sum_putts += score.putts
  end
  # rubocop:disable Layout/LineLength
  raise generate_error_message(round, front_nine_strokes, sum_strokes, 'front nine strokes') unless sum_strokes == front_nine_strokes

  raise generate_error_message(round, front_nine_putts, sum_putts, 'front nine putts') unless sum_putts == front_nine_putts

  # rubocop:enable Layout/LineLength
  back_sum_strokes = 0
  back_sum_putts = 0
  (10..18).each do |hole_number|
    score = round.score(hole_number)
    sum_strokes += score.strokes
    back_sum_strokes += score.strokes
    sum_putts += score.putts
    back_sum_putts += score.putts
  end
  # rubocop:disable Layout/LineLength
  raise generate_error_message(round, back_nine_strokes, back_sum_strokes, 'back nine strokes') unless back_sum_strokes == back_nine_strokes

  raise generate_error_message(round, back_nine_putts, back_sum_putts, 'back nine putts') unless back_sum_putts == back_nine_putts

  raise generate_error_message(round, stroke_total, sum_strokes, 'total strokes') unless sum_strokes == stroke_total

  raise generate_error_message(round, putt_total, sum_putts, 'total putts') unless sum_putts == putt_total
end

def generate_error_message(round, expected, sum, type)
  "Round #{round.date} at Course: #{round.course.name} tee: #{round.tee.color} #{type} sum problem: expected total=#{expected} hole total=#{sum}"
  # rubocop:enable Layout/LineLength
end
