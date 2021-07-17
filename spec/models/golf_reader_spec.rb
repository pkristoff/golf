# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe GolfReader, type: :model do
  describe 'Reading excel spreadsheet' do
    it 'read' do
      golf_reader = GolfReader.new('spec/fixtures/Golf.xlsx')
      expect_knights_play_course(golf_reader.course("Knight's play 1-9"),
                                 "Knight's play 1-9",
                                 TeeHoleInfo::HOLE_INFO_KN_1_9)
      expect_knights_play_course(golf_reader.course("Knight's play 10-18"),
                                 "Knight's play 10-18",
                                 TeeHoleInfo::HOLE_INFO_KN_10_18)
      expect_knights_play_course(golf_reader.course("Knight's play 19-27"),
                                 "Knight's play 19-27",
                                 TeeHoleInfo::HOLE_INFO_KN_19_27)
      course = golf_reader.course('Lochmere')
      expect_lochmere(course)
    end
    it 'read rounds' do
      golf_reader = GolfReader.new('spec/fixtures/Golf.xlsx')
      course = golf_reader.course("Knight's play 1-9")
      TeeHoleInfo::HOLE_INFO_KN_1_9[:Black_rounds].each do |round_info|
        expect_knights_play_round(golf_reader.round(Date.strptime(round_info[0], '%m/%d/%y'),
                                                    course,
                                                    'Black'),
                                  round_info[1..10])
      end
      course = golf_reader.course("Knight's play 10-18")
      TeeHoleInfo::HOLE_INFO_KN_10_18[:Black_rounds].each do |round_info|
        # puts "round_info[0]=#{round_info[0]}"
        expect_knights_play_round(golf_reader.round(Date.strptime(round_info[0], '%m/%d/%y'),
                                                    course,
                                                    'Black'),
                                  round_info[1..10])
      end
      course = golf_reader.course('Lochmere')
      TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue_rounds].each do |round_info|
        expect_lochmere_round(golf_reader.round(Date.strptime(round_info[0], '%m/%d/%y'),
                                                course,
                                                'Blue'),
                              round_info[1..20])
      end
    end
    it 'reads and saves to DB' do
      GolfReader.new('spec/fixtures/Golf.xlsx')
      course = Course.find_by(name: 'Lochmere')
      expect_knights_play_course(Course.find_by(name: "Knight's play 1-9"),
                                 "Knight's play 1-9",
                                 TeeHoleInfo::HOLE_INFO_KN_1_9)
      expect_knights_play_course(Course.find_by(name: "Knight's play 10-18"),
                                 "Knight's play 10-18",
                                 TeeHoleInfo::HOLE_INFO_KN_10_18)
      expect_knights_play_course(Course.find_by(name: "Knight's play 19-27"),
                                 "Knight's play 19-27",
                                 TeeHoleInfo::HOLE_INFO_KN_19_27)
      expect_lochmere(course)
    end
  end
end

def expect_address(course, expected_address)
  expect(course.address.street_1).to eq(expected_address[0])
  expect(course.address.street_2).to eq(expected_address[1])
  expect(course.address.city).to eq(expected_address[2])
  expect(course.address.state).to eq(expected_address[3])
  expect(course.address.zip_code).to eq(expected_address[4])
end

def expect_tee(course, color, rating, slope, hole_info)
  tee = course.tee(color)
  expect(tee).to be_truthy, "Tee not found #{color} for course #{course.name}"
  # rubocop:disable Layout/LineLength
  expect(tee.rating.to_f).to eq(rating), "rating incorrect got #{tee.rating.to_f} expected #{rating} for tee: #{tee.color} course: #{course.name}"
  expect(tee.slope.to_i).to eq(slope), "slope incorrect got #{tee.slope.to_i} expected #{slope} for tee: #{tee.color} course: #{course.name}"
  offset = 0
  hole_info.each do |info|
    hole_num = info[0]
    yardage = info[1]
    par = info[2]
    hdcp = info[3]
    offset += 1 if hole_num.nil?
    next if hole_num.nil?

    hole = tee.hole(hole_num)
    expect(hole.yardage).to eq(yardage), "Yardage mismatch expected: #{yardage} got: #{hole.yardage} for hole:#{hole.number}, tee: #{tee.color}, course: #{course.name}"
    expect(hole.par).to eq(par)
    expect(hole.hdcp).to eq(hdcp), "HDCP mismatch expected: #{hdcp} got: #{hole.hdcp} for hole:#{hole.number}, tee: #{tee.color}, course: #{course.name}"
    expect(hole.number).to eq(hole_num)
    expect(hole.tee).to be(tee)
    # rubocop:enable Layout/LineLength
  end
  expect(tee.sorted_holes.size).to eq(hole_info.size - offset)
end

def expect_lochmere(course)
  expect(course).to be_truthy, 'Course not found: Lochmere'
  expect(course.name).to eq('Lochmere')

  expect_address(course, TeeHoleInfo::LOCHMERE_ADDRESS)

  expect_tee(course, 'Black', 71.6, 139, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
  expect_tee(course, 'Blue', 69.5, 132, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
  expect_tee(course, 'White', 67.1, 123, TeeHoleInfo::HOLE_INFO_LOCHMERE[:White])
end

def expect_knights_play_course(course, name, hole_info)
  expect(course).to be_truthy, "Course not found: #{name}"
  expect_address(course, TeeHoleInfo::KNIGHTS_PLAY_ADDRESS)

  expect_tee(course, 'Black', 71.6, 139, hole_info[:Black])
  expect_tee(course, 'White', 54, 126, hole_info[:White])
  expect_tee(course, 'Blue', 27, 113, hole_info[:Blue])
end

def expect_knights_play_round(round, score_info)
  expect(round).to be_truthy
  nine_strokes = 0
  nine_putts = 0
  score_info.each_with_index do |hole_score, index|
    if index == 9
      expect(hole_score[0]).to eq(nine_strokes)
      expect(hole_score[1]).to eq(nine_putts)
    else
      score = round.score_holes[index].score
      expect(score.strokes).to eq(hole_score[0]),
                               "stroke mismatch stroke=#{score.strokes} expected=#{hole_score[0]} index=#{index}"
      expect(score.putts).to eq(hole_score[1]),
                             "putt mismatch putts=#{score.putts} expected=#{hole_score[1]} index=#{index}"
      expect(score.penalties).to eq(hole_score[2]),
                                 "penalty mismatch penalties=#{score.penalties} expected=#{hole_score[2]} index=#{index}"
      nine_strokes += score.strokes
      nine_putts += score.putts
    end
  end
end

def expect_lochmere_round(round, score_info)
  expect(round).to be_truthy
  front_nine_strokes = 0
  back_nine_strokes = 0
  front_nine_putts = 0
  back_nine_putts = 0
  doing_front_nine = true
  # puts "round.scores=#{round.scores.map {|score| "#{score.hole.number} #{score.strokes}"}}"
  hole_num = 1
  score_info.each_with_index do |hole_score, index|
    # puts "hole_score=#{hole_score} index=#{index}"
    case index
    when 9
      expect(hole_score[0]).to eq(front_nine_strokes)
      expect(hole_score[1]).to eq(front_nine_putts)
      doing_front_nine = false
    when 19
      expect(hole_score[0]).to eq(back_nine_strokes),
                               "total mismatch expected=#{hole_score[0]} actual=#{back_nine_strokes} index=#{index}"
      expect(hole_score[1]).to eq(back_nine_putts)
    when 20
      expect(hole_score[0]).to eq(front_nine_strokes + back_nine_strokes)
      expect(hole_score[1]).to eq(front_nine_putts + back_nine_putts)
    else
      score = round.score_holes[hole_num - 1].score
      unless score.strokes == hole_score[0]
        puts "round.scores.map(&:score)=#{score_info.map { |xxx| xxx[0] }}"
        puts "round.scores.map(&:score)=#{round.scores.map(&:score)}"
      end
      expect(score.strokes).to eq(hole_score[0]),
                               "stroke mismatch stroke=#{score.strokes} expected=#{hole_score[0]} index=#{index}"
      expect(score.putts).to eq(hole_score[1]),
                             "putt mismatch putts=#{score.putts} expected=#{hole_score[1]} index=#{index}"
      expect(score.penalties).to eq(hole_score[2]),
                                 "penalty mismatch penalties=#{score.penalties} expected=#{hole_score[2]} index=#{index}"
      front_nine_strokes += score.strokes if doing_front_nine
      front_nine_putts += score.putts if doing_front_nine
      back_nine_strokes += score.strokes unless doing_front_nine
      back_nine_putts += score.putts unless doing_front_nine
      hole_num += 1
    end
  end
end
