# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe Course, type: :model do
  describe 'basic creation' do
    it 'default values' do
      course = Course.new(name: 'Lochmere')
      expect(course.name).to eq('Lochmere')
    end
    it 'duplicate course name case insensitive' do
      FactoryBot.create(:course, name: 'george')
      expect(Course.all.size).to eq(1)
      # rubocop:disable Layout/LineLength
      expect { Course.create!(name: 'george') }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Name has already been taken, Address is invalid')
      # rubocop:enable Layout/LineLength
      course2 = Course.create(name: 'george')
      expect(course2.errors[:name][0]).to eq('has already been taken')
    end
    it 'tees' do
      course = Course.new(name: 'Lochmere')
      course.address.street1 = '555 Xxx Ave.'
      course.address.city = 'Clarksville'
      course.address.state = 'IN'
      course.address.state = '47529'
      course.save!
      course.add_tee(nil, 'Black', 67.3, 70.7, TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO])
      expect(course.tees.size).to eq(1)

      tee = course.tees.first
      expect(tee.color).to eq('Black')
    end
  end
  describe 'Factory create' do
    it 'address' do
      course = FactoryBot.create(:course)
      address = course.address
      expect(address.street1).to eq('555 Xxx Ave.')
      expect(address.street2).to eq('<nothing>')
      expect(address.city).to eq('Clarksville')
      expect(address.state).to eq('IN')
      expect(address.zip_code).to eq('47529')
    end
    it 'tees' do
      course = FactoryBot.create(:course)
      expect_tee(course, 'Black', 71.6, 139, 18)
      expect_tee(course, 'Blue', 69.5, 132, 18)
      expect_tee(course, 'White', 67.1, 123, 18)
      expect_tee(course, 'Red', 63.6, 106, 18)
    end
  end
  describe 'validation' do
    it 'should raise error if a course has two tees of same color' do
      course = FactoryBot.create(:course)
      tee1 = course.add_tee(nil, 'Black', 71.7, 140, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
      expect(tee1.errors[:color][0]).to eq('has already been taken')
      # case insensitive
      tee2 = course.add_tee(nil, 'Black', 71.7, 140, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
      expect(tee2.errors[:color][0]).to eq('has already been taken')
    end
    it 'should if number_of_holes eq 9 or 18' do
      course = FactoryBot.create(:course)
      course.number_of_holes = 9
      expect(course.valid?).to be_truthy
      course.number_of_holes = 18
      expect(course.valid?).to be_truthy
    end
    it 'should if number_of_holes eq 0, 1, 8, 10, 17, 19' do
      course = FactoryBot.create(:course)
      [0, 1, 8, 10, 17, 19].each do |num|
        course.number_of_holes = num
        expect(course.valid?).to be_falsey
      end
    end
  end
  describe 'destroy' do
    it 'should remove course, address, tee, holes' do
      course = FactoryBot.create(:course)
      expect(Course.all.size).to eq(1)
      expect(Tee.all.size).to eq(4)
      expect(Hole.all.size).to eq(72)
      course.destroy
      expect(Course.all.size).to eq(0)
      expect(Tee.all.size).to eq(0)
      expect(Hole.all.size).to eq(0)
    end
  end
  describe 'Sorting tees' do
    it 'empty tees' do
      course = Course.new
      expect(course.sorted_tees).to be_empty
    end
    it 'already sorted tees' do
      course = FactoryBot.create(:course)
      sorted_tees = course.sorted_tees
      expect(sorted_tees.size).to eq(4)
      expect(sorted_tees[0].color).to eq('Black')
      expect(sorted_tees[1].color).to eq('Blue')
      expect(sorted_tees[2].color).to eq('Red')
      expect(sorted_tees[3].color).to eq('White')
    end
  end

  # expect tee info
  #
  # === Parameters:
  #
  # * <tt>:course</tt> Course
  # * <tt>:color</tt> color of tee
  # * <tt>:rating</tt> Number rating
  # * <tt>:slope</tt> Number slope
  # * <tt>:num_of_holes</tt> number of holes of course
  #
  def expect_tee(course, color, rating, slope, num_of_holes)
    tee = course.tee(color)
    expect(tee).to be_truthy
    expect(tee.rating.to_f).to eq(rating)
    expect(tee.slope).to eq(slope)
    expect(tee.holes.size).to eq(num_of_holes)
    tee.sorted_holes.each_with_index do |hole, index|
      expect(hole.number).to eq(index + 1)
      expect(hole.tee).to be(tee)
    end
  end
end
