# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe Course, type: :model do
  describe 'basic creation' do
    it 'default values' do
      course = Course.new(name: 'Lochmere')
      expect(course.name).to eq('Lochmere')
    end
    it 'tees' do
      course = Course.new(name: 'Lochmere')
      course.add_tee('black', 67.3, 70.7, TeeHoleInfo::BLACK_HOLE_INFO)
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
      expect(address.zip_code).to eq(47_529)
    end
    it 'tees' do
      course = FactoryBot.create(:course)
      expect_tee(course, 'Black', 71.6, 139, 18)
      expect_tee(course, 'Blue', 69.5, 132, 18)
      expect_tee(course, 'White', 67.1, 123, 18)
      expect_tee(course, 'Red', 63.6, 106, 18)
    end
  end

  def expect_tee(course, color, rating, slope, num_of_holes)
    tee = course.tee(color)
    expect(tee).to be_truthy
    puts "tee.ratig:#{tee.rating.class}=rating#{rating.class}: eq?#{tee.holes == rating}"
    expect(tee.rating.to_f).to eq(rating)
    expect(tee.slope).to eq(slope)
    expect(tee.holes.size).to eq(num_of_holes)
    tee.holes.each_with_index do |hole, index|
      expect(hole.number).to eq(index + 1)
      expect(hole.tee).to be(tee)
    end
  end
end
