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
      FactoryBot.create(:course)
      expect(Course.all.size).to eq(1)
      # rubocop:disable Layout/LineLength
      expect { Course.create!(name: 'george') }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Name has already been taken, Address is invalid')
      # rubocop:enable Layout/LineLength
      course2 = Course.create(name: 'george')
      expect(course2.errors[:name][0]).to eq('has already been taken')
    end
    it 'tees' do
      course = Course.new(name: 'Lochmere')
      course.address.street_1 = '555 Xxx Ave.'
      course.address.city = 'Clarksville'
      course.address.state = 'IN'
      course.address.state = '47529'
      course.save!
      course.add_tee(nil, 'black', 67.3, 70.7, TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO])
      expect(course.tees.size).to eq(1)

      tee = course.tees.first
      expect(tee.color).to eq('black')
    end
  end
  describe 'Factory create' do
    it 'address' do
      course = FactoryBot.create(:course)
      address = course.address
      expect(address.street_1).to eq('555 Xxx Ave.')
      expect(address.street_2).to eq('<nothing>')
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
  describe 'dupliate tee colors' do
    it 'should raise error if a course has two tees of same color' do
      course = FactoryBot.create(:course)
      tee1 = course.add_tee(nil, 'Black', 71.7, 140, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
      expect(tee1.errors[:color][0]).to eq('has already been taken')
      # case insensitive
      tee2 = course.add_tee(nil, 'black', 71.7, 140, TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black])
      expect(tee2.errors[:color][0]).to eq('has already been taken')
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

  def expect_tee(course, color, rating, slope, num_of_holes)
    tee = course.tee(color)
    expect(tee).to be_truthy
    expect(tee.rating.to_f).to eq(rating)
    expect(tee.slope).to eq(slope)
    expect(tee.holes.size).to eq(num_of_holes)
    tee.holes.each_with_index do |hole, index|
      expect(hole.number).to eq(index + 1)
      expect(hole.tee).to be(tee)
    end
  end
end
