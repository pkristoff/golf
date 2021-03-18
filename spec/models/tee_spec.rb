# frozen_string_literal: true

describe Tee, type: :model do
  describe 'basic creation' do
    it 'default values' do
      tee = Tee.new(color: 'Black', slope: 3.4, rating: 5.5)
      expect(tee.color).to eq('Black')
      expect(tee.slope).to eq(3.4)
      expect(tee.rating).to eq(5.5)
      expect(tee.holes.size).to eq(0)
    end
  end
  describe 'holes' do
    describe 'creation' do
      it 'create 9 holes' do
        tee = Tee.new(color: 'Black', slope: 3.4, rating: 5.5)
        expect(tee.color).to eq('Black')
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
        expect(course.name).to eq('for factorybot tee')
        expect(tee.color).to eq('Black')
        expect(tee.slope).to eq(62.9)
        expect(tee.rating).to eq(60.7)
        expect(tee.holes.size).to eq(18)
        tee.sorted_holes.each_with_index do |hole, index|
          expect(hole.number).to eq(index + 1)
          expect(hole.tee).to be(tee)
        end
      end
    end
    describe 'holes_in_order' do
      it 'should the holes in order 18 holes' do
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
      it 'should the holes in order 9 holes' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_KN_19_27[:Black])
        holes_in_order = tee.holes_inorder_with_yardage_totals
        holes_in_order.each_with_index do |hole, index|
          hole_info = TeeHoleInfo::HOLE_INFO_KN_19_27[:Black][index]
          expect(hole).to eq(hole_info[1]) if hole.is_a? Integer
          expect(hole.number).to eq(hole_info[0]) unless hole.is_a? Integer
          expect(hole.yardage).to eq(hole_info[1]) unless hole.is_a? Integer
          expect(hole.par).to eq(hole_info[2]) unless hole.is_a? Integer
          expect(hole.hdcp).to eq(hole_info[3]) unless hole.is_a? Integer
        end
      end
      it 'should the holes in order 1 hole' do
        tee = FactoryBot.create(:tee)
        holes_in_order = tee.holes_inorder_with_yardage_totals
        tee_info = [[1, 350, 4, 9],
                    [2, 350, 4, 9],
                    [3, 350, 4, 9],
                    [4, 350, 4, 9],
                    [5, 350, 4, 9],
                    [6, 350, 4, 9],
                    [7, 350, 4, 9],
                    [8, 350, 4, 9],
                    [9, 350, 4, 9],
                    [nil, 3150, 36],
                    [10, 350, 4, 9],
                    [11, 350, 4, 9],
                    [12, 350, 4, 9],
                    [13, 350, 4, 9],
                    [14, 350, 4, 9],
                    [15, 350, 4, 9],
                    [16, 350, 4, 9],
                    [17, 350, 4, 9],
                    [18, 350, 4, 9],
                    [nil, 3150, 36],
                    [nil, 6300, 72]]
        holes_in_order.each_with_index do |hole, index|
          hole_info = tee_info[index]
          expect(hole).to eq(hole_info[1]) if hole.is_a? Integer
          expect(hole.number).to eq(hole_info[0]) unless hole.is_a? Integer
          expect(hole.yardage).to eq(hole_info[1]) unless hole.is_a? Integer
          expect(hole.par).to eq(hole_info[2]) unless hole.is_a? Integer
          expect(hole.hdcp).to eq(hole_info[3]) unless hole.is_a? Integer
        end
      end
    end
    describe 'add  holes' do
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
    describe 'next hole' do
      it 'should return hole number 2 given hole number 1' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
        hole_one = Hole.find_by(number: 1, tee: tee)
        hole_two = tee.next_hole(hole_one)
        expect(hole_two.number).to eq(2)
      end
      it 'should return hole number 1 given hole number 18' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
        hole_one = Hole.find_by(number: 18, tee: tee)
        hole_two = tee.next_hole(hole_one)
        expect(hole_two.number).to eq(1)
      end
      it 'should return hole number 1 given hole number 9 and 9 hole golf course' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_KN_1_9[:Black])
        hole_nine = Hole.find_by(number: 9, tee: tee)
        hole_one = tee.next_hole(hole_nine)
        expect(hole_one.number).to eq(1)
      end
    end
  end
  describe 'validation' do
    it 'tee is valid' do
      course = Course.new
      tee = Tee.new(color: 'red', slope: 0, rating: 0, course: course)
      expect(tee.valid?).to be_truthy
    end
    it 'presence of color' do
      course = Course.new
      tee = Tee.new(color: '', slope: 0, rating: 0, course: course)
      expect(tee.valid?).to be_falsey
    end
    it 'presence of slope' do
      course = Course.new
      tee = Tee.new(color: 'red', slope: nil, rating: 0, course: course)
      expect(tee.valid?).to be_falsey
    end
    it 'presence of rating' do
      course = Course.new
      tee = Tee.new(color: 'red', slope: 0, rating: nil, course: course)
      expect(tee.valid?).to be_falsey
    end
  end
end
