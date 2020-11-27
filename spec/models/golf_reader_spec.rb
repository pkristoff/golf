# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe GolfReader, type: :model do
  describe 'Reading excel spreadsheet' do
    it 'read' do
      golf_reader = GolfReader.new('spec/fixtures/Golf.xlsx')
      course = golf_reader.course('Lochmere')
      expect_lochmere(course)
      expect_knights_play(golf_reader.course("Knight's play 1-9"))
      expect_knights_play(golf_reader.course("Knight's play 10-18"))
      expect_knights_play(golf_reader.course("Knight's play 19-27"))
    end
    it 'reads and saves to DB' do
      GolfReader.new('spec/fixtures/Golf.xlsx')
      course = Course.find_by(name: 'Lochmere')
      expect_lochmere(course)
      expect_knights_play(Course.find_by(name: "Knight's play 1-9"))
    end
  end
end

def expect_address(course)
  expect(course.address.street_1).to eq(TeeHoleInfo::STREET_1)
  expect(course.address.street_2).to eq(TeeHoleInfo::STREET_2)
  expect(course.address.city).to eq(TeeHoleInfo::CITY)
  expect(course.address.state).to eq(TeeHoleInfo::STATE)
  expect(course.address.zip_code).to eq(TeeHoleInfo::ZIP_CODE)
end

def expect_tee(course, color, rating, slope, hole_info)
  tee = course.tee(color)
  expect(tee).to be_truthy, "Tee not found #{color} for course #{course.name}"
  # rubocop:disable Layout/LineLength
  expect(tee.rating.to_f).to eq(rating), "rating incorrect got #{tee.rating.to_f} expected #{rating} for tee: #{tee.color} course: #{course.name}"
  expect(tee.slope.to_i).to eq(slope), "slope incorrect got #{tee.slope.to_i} expected #{slope} for tee: #{tee.color} course: #{course.name}"
  expect(tee.holes.size).to eq(hole_info.size - 3)
  hole_info.each do |info|
    hole_num = info[0]
    yardage = info[1]
    par = info[2]
    hdcp = info[3]
    next if hole_num.nil?

    hole = tee.hole(hole_num)
    expect(hole.yardage).to eq(yardage), "Yardage mismatch expected: #{yardage} got: #{hole.yardage} for hole:#{hole.number}, tee: #{tee.color}, course: #{course.name}"
    # rubocop:enable Layout/LineLength
    expect(hole.par).to eq(par)
    expect(hole.hdcp).to eq(hdcp)
    expect(hole.number).to eq(hole_num)
    expect(hole.tee).to be(tee)
  end
end

def expect_lochmere(course)
  expect(course).to be_truthy, 'Course not found: Lochmere'
  expect(course.name).to eq('Lochmere')

  expect_address(course)

  expect_tee(course, 'Black', 71.6, 139, TeeHoleInfo::BLACK_HOLE_INFO)
  expect_tee(course, 'Blue', 69.5, 132, TeeHoleInfo::BLUE_HOLE_INFO)
  expect_tee(course, 'White', 67.1, 123, TeeHoleInfo::WHITE_HOLE_INFO)
end

def expect_knights_play(course)
  expect(course).to be_truthy, "Course not found: Knight's play 1-9"
end
