# frozen_string_literal: true

describe Tee, type: :model do
  describe 'basic creation' do
    it 'default values' do
      tee = Tee.new(color: 'black', slope: 3.4, rating: 5.5)
      expect(tee.color).to eq('black')
      expect(tee.slope).to eq(3.4)
      expect(tee.rating).to eq(5.5)
      expect(tee.holes.size).to eq(0)
    end
  end
  describe 'holes' do
    it 'create 9 holes' do
      tee = Tee.new(color: 'black', slope: 3.4, rating: 5.5)
      expect(tee.color).to eq('black')
      expect(tee.slope).to eq(3.4)
      expect(tee.rating).to eq(5.5)
      tee.add_9_holes
      expect(tee.holes.size).to eq(9)
      tee.holes.each_with_index do |hole, index|
        expect(hole.number).to eq(index + 1)
        expect(hole.tee).to be(tee)
      end
    end
    it 'create 18 holes' do
      tee = Tee.new(color: 'red', slope: 0, rating: 0)
      expect(tee.color).to eq('red')
      expect(tee.slope).to eq(0)
      expect(tee.rating).to eq(0)
      tee.add_18_holes
      expect(tee.holes.size).to eq(18)
      tee.holes.each_with_index do |hole, index|
        expect(hole.number).to eq(index + 1)
        expect(hole.tee).to be(tee)
      end
    end
    it 'should create a factory tee' do
      tee = FactoryBot.create(:tee)
      course = tee.course
      expect(course.name).to eq('Factory-bot for Tee')
      expect(tee.color).to eq('black')
      expect(tee.slope).to eq(62.9)
      expect(tee.rating).to eq(60.7)
      expect(tee.holes.size).to eq(18)
      tee.holes.each_with_index do |hole, index|
        expect(hole.number).to eq(index + 1)
        expect(hole.tee).to be(tee)
      end
    end
    it 'should the holes in order' do
      tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
      holes_in_order = tee.holes_inorder_with_yardage_totals
      holes_in_order.each_with_index do |hole, index|
        hole_info = TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue][index]
        expect(hole).to eq(hole_info[1]) if hole.is_a? Integer
        expect(hole.number).to eq(hole_info[0]) unless hole.is_a? Integer
        expect(hole.yardage).to eq(hole_info[1]) unless hole.is_a? Integer
        expect(hole.par).to eq(hole_info[2]) unless hole.is_a? Integer
        expect(hole.hdcp).to eq(hole_info[3]) unless hole.is_a? Integer
      end
    end
    it 'should add hole to tee' do
      tee = Tee.new(color: 'red', slope: 0, rating: 0)
      hole = tee.add_hole(3, 500, 4, 7)
      expect(tee.color).to eq('red')
      expect(tee.slope).to eq(0)
      expect(tee.rating).to eq(0)
      expect(tee.holes.size).to eq(1)
      expect(tee.holes.first).to eql(hole)
      expect(hole.tee).to eql(tee)
    end
  end
end
