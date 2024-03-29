# frozen_string_literal: true

describe Tee, type: :model do
  describe 'basic creation' do
    it 'default values' do
      tee = described_class.new(color: 'Black', slope: 3.4, rating: 5.5)
      expect(tee.color).to eq('Black')
      expect(tee.slope).to eq(3.4)
      expect(tee.rating).to eq(5.5)
      expect(tee.holes.size).to eq(0)
    end
  end

  describe 'holes' do
    describe 'creation' do
      it 'create 9 holes' do
        tee = described_class.new(color: 'Black', slope: 3.4, rating: 5.5)
        expect(tee.color).to eq('Black')
        expect(tee.slope).to eq(3.4)
        expect(tee.rating).to eq(5.5)
        tee.add_9_holes
        expect(tee.holes.size).to eq(9)
        tee.sorted_holes.each_with_index do |hole, index|
          expect(hole.number).to eq(index + 1)
          expect(hole.tee).to be(tee)
        end
      end

      it 'create 18 holes' do
        tee = described_class.new(color: 'red', slope: 0, rating: 0)
        expect(tee.color).to eq('red')
        expect(tee.slope).to eq(0)
        expect(tee.rating).to eq(0)
        tee.add_18_holes
        expect(tee.holes.size).to eq(18)
        tee.sorted_holes.each_with_index do |hole, index|
          expect(hole.number).to eq(index + 1)
          expect(hole.tee).to be(tee)
        end
      end

      it 'create a factory tee' do
        tee = FactoryBot.create(:tee)
        course = tee.course
        expect(course.name).to eq('for factorybot tee')
        expect(tee.color).to eq('Black')
        expect(tee.slope).to eq(113)
        expect(tee.rating).to eq(72)
        expect(tee.holes.size).to eq(18)
        tee.sorted_holes.each_with_index do |hole, index|
          expect(hole.number).to eq(index + 1)
          expect(hole.tee).to be(tee)
        end
      end
    end

    describe 'holes_in_order' do
      it 'the holes in order 18 holes' do
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

      it 'the holes in order 9 holes' do
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

      it 'the holes in order 1 hole' do
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

    describe 'add holes' do
      it 'add hole to tee' do
        tee = described_class.new(color: 'red', slope: 0, rating: 0)
        hole = tee.add_hole(3, 500, 4, 7)
        expect(tee.color).to eq('red')
        expect(tee.slope).to eq(0)
        expect(tee.rating).to eq(0)
        expect(tee.holes.size).to eq(1)
        expect(tee.sorted_holes.first).to eql(hole)
        expect(hole.tee).to eql(tee)
      end
    end

    describe 'next hole' do
      it 'return hole number 2 given hole number 1' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
        hole_one = Hole.find_by(number: 1, tee: tee)
        hole_two = tee.next_hole(hole_one)
        expect(hole_two.number).to eq(2)
      end

      it 'return hole number 1 given hole number 18' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
        hole_one = Hole.find_by(number: 18, tee: tee)
        hole_two = tee.next_hole(hole_one)
        expect(hole_two.number).to eq(1)
      end

      it 'return hole number 1 given hole number 9 and 9 hole golf course' do
        tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_KN_1_9[:Black])
        hole_nine = Hole.find_by(number: 9, tee: tee)
        hole_one = tee.next_hole(hole_nine)
        expect(hole_one.number).to eq(1)
      end
    end
  end

  describe 'adjust_number_of_holes' do
    it 'remove back nine' do
      tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
      unadjusted_par = tee.total_par
      course = tee.course
      expect(Hole.all.size).to eq(18)
      tee.adjust_number_of_holes
      expect(tee.number_of_holes).to eq(18)
      course.number_of_holes = 9
      tee.adjust_number_of_holes
      expect(tee.number_of_holes).to eq(9)
      expect(Hole.all.size).to eq(9)
      expect(tee.total_par).not_to eq(unadjusted_par)
      expect(tee.total_par).to eq(35)
    end

    it 'add back nine' do
      tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_KN_1_9[:Black])
      course = tee.course
      expect(Hole.all.size).to eq(9)
      # no adjustment neded
      tee.adjust_number_of_holes
      expect(tee.number_of_holes).to eq(9)
      course.number_of_holes = 18
      tee.adjust_number_of_holes
      expect(tee.number_of_holes).to eq(18)
      expect(Hole.all.size).to eq(18)
    end
  end

  describe 'validation' do
    it 'tee is valid' do
      course = Course.new
      tee = described_class.new(color: 'red', slope: 0, rating: 0, course: course)
      expect(tee).to be_valid
    end

    it 'presence of color' do
      course = Course.new
      tee = described_class.new(color: '', slope: 0, rating: 0, course: course)
      expect(tee).not_to be_valid
    end

    it 'presence of slope' do
      course = Course.new
      tee = described_class.new(color: 'red', slope: nil, rating: 0, course: course)
      expect(tee).not_to be_valid
    end

    it 'presence of rating' do
      course = Course.new
      tee = described_class.new(color: 'red', slope: 0, rating: nil, course: course)
      expect(tee).not_to be_valid
    end
  end

  describe 'max_hdcp_score' do
    it 'course_hdcp is 0..9' do
      [0..9].each do |ch|
        expect(described_class.max_hdcp_score(ch, 5)).to eq(7)
        expect(described_class.max_hdcp_score(ch, 4)).to eq(6)
        expect(described_class.max_hdcp_score(ch, 3)).to eq(5)
      end
    end

    it 'course_hdcp is 10..19' do
      [10..19].each do |ch|
        expect(described_class.max_hdcp_score(ch, 5)).to eq(7)
        expect(described_class.max_hdcp_score(ch, 4)).to eq(7)
        expect(described_class.max_hdcp_score(ch, 3)).to eq(7)
      end
    end

    it 'course_hdcp is 20..29' do
      [20..29].each do |ch|
        expect(described_class.max_hdcp_score(ch, 5)).to eq(8)
        expect(described_class.max_hdcp_score(ch, 4)).to eq(8)
        expect(described_class.max_hdcp_score(ch, 3)).to eq(8)
      end
    end

    it 'course_hdcp is 30..39' do
      [30..39].each do |ch|
        expect(described_class.max_hdcp_score(ch, 5)).to eq(9)
        expect(described_class.max_hdcp_score(ch, 4)).to eq(9)
        expect(described_class.max_hdcp_score(ch, 3)).to eq(9)
      end
    end

    it 'course_hdcp is 40..99' do
      [40..99].each do |ch|
        expect(described_class.max_hdcp_score(ch, 5)).to eq(10)
        expect(described_class.max_hdcp_score(ch, 4)).to eq(10)
        expect(described_class.max_hdcp_score(ch, 3)).to eq(10)
      end
    end
  end

  describe 'adjusted_score' do
    [0..9].each do |course_hdcp|
      it "course_hdcp: #{course_hdcp} 0-9" do
        expect(described_class.calc_adjusted_score(course_hdcp, 3, 3)).to eq(3)
        expect(described_class.calc_adjusted_score(course_hdcp, 4, 3)).to eq(4)
        expect(described_class.calc_adjusted_score(course_hdcp, 5, 3)).to eq(5)
        expect(described_class.calc_adjusted_score(course_hdcp, 6, 3)).to eq(5)
      end
    end
    [10..19].each do |course_hdcp|
      it "course_hdcp: #{course_hdcp} 10-19" do
        expect(described_class.calc_adjusted_score(course_hdcp, 6, 3)).to eq(6)
        expect(described_class.calc_adjusted_score(course_hdcp, 7, 3)).to eq(7)
        expect(described_class.calc_adjusted_score(course_hdcp, 8, 3)).to eq(7)
      end
    end
    [20..29].each do |course_hdcp|
      it "course_hdcp: #{course_hdcp} 20-29" do
        expect(described_class.calc_adjusted_score(course_hdcp, 7, 3)).to eq(7)
        expect(described_class.calc_adjusted_score(course_hdcp, 8, 3)).to eq(8)
        expect(described_class.calc_adjusted_score(course_hdcp, 9, 3)).to eq(8)
      end
    end
    [30..39].each do |course_hdcp|
      it "course_hdcp: #{course_hdcp} 30-39" do
        expect(described_class.calc_adjusted_score(course_hdcp, 8, 3)).to eq(8)
        expect(described_class.calc_adjusted_score(course_hdcp, 9, 3)).to eq(9)
        expect(described_class.calc_adjusted_score(course_hdcp, 10, 3)).to eq(9)
      end
    end
    [40..99].each do |course_hdcp|
      it "course_hdcp: #{course_hdcp} 40-99" do
        expect(described_class.calc_adjusted_score(course_hdcp, 9, 3)).to eq(9)
        expect(described_class.calc_adjusted_score(course_hdcp, 10, 3)).to eq(10)
        expect(described_class.calc_adjusted_score(course_hdcp, 11, 3)).to eq(10)
      end
    end
  end

  describe 'Score Differential' do
    it 'ags:85' do
      ags = 85
      course_rating = 69.3
      slope_rating = 117
      expect(described_class.calc_score_differential(ags, course_rating, slope_rating)).to eq(15.2)
    end
  end

  describe 'Handicap Index' do
    let(:handicap_differentials) { [10, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51] }
    let(:handicap_differentials_r) { handicap_differentials.reverse }

    it 'one' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(1)).first).to eq(5.7)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(1)).first).to eq(45.1)
    end

    it 'two' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(2)).first).to eq(6.7)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(2)).first).to eq(44.1)
    end

    it 'three' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(3)).first).to eq(7.6)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(3)).first).to eq(43.1)
    end

    it 'four' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(4)).first).to eq(8.6)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(4)).first).to eq(42.2)
    end

    it 'five' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(5)).first).to eq(9.6)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(5)).first).to eq(41.2)
    end

    it 'six' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(6)).first).to eq(10.0)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(6)).first).to eq(39.3)
    end

    it 'seven' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(7)).first).to eq(11.0)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(7)).first).to eq(38.4)
    end

    it 'eight' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(8)).first).to eq(11.0)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(8)).first).to eq(36.4)
    end

    it 'nine' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(9)).first).to eq(12.1)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(9)).first).to eq(35.5)
    end

    it 'ten' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(10)).first).to eq(12.1)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(10)).first).to eq(33.6)
    end

    it 'eleven' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(11)).first).to eq(12.1)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(11)).first).to eq(31.6)
    end

    it 'twelve' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(12)).first).to eq(13.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(12)).first).to eq(30.7)
    end

    it 'thirteen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(13)).first).to eq(13.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(13)).first).to eq(28.8)
    end

    it 'fourteen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(14)).first).to eq(13.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(14)).first).to eq(26.8)
    end

    it 'fifteen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(15)).first).to eq(14.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(15)).first).to eq(25.9)
    end

    it 'sixteen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(16)).first).to eq(14.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(16)).first).to eq(24.0)
    end

    it 'seventeen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(17)).first).to eq(15.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(17)).first).to eq(23.0)
    end

    it 'eighteen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(18)).first).to eq(15.2)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(18)).first).to eq(21.1)
    end

    it 'nineteen' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(19)).first).to eq(16.1)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(19)).first).to eq(20.1)
    end

    it 'twenty' do
      expect(described_class.final_calc_handicap_index(handicap_differentials.first(20)).first).to eq(17.1)
      expect(described_class.final_calc_handicap_index(handicap_differentials_r.first(20)).first).to eq(19.2)
    end

    it 'example 1' do
      # https://www.usga.org/content/usga/home-page/handicapping/roh/Content/rules/5%202%20Calculation%20of%20a%20Handicap%20Index.htm
      expectd_result = 34.1
      handicap_differentials = [40.7, 42.4, 36.1]
      expect(described_class.final_calc_handicap_index(handicap_differentials).first).to eq((expectd_result * 0.96).truncate(1))
    end

    it 'example 2' do
      # https://www.usga.org/content/usga/home-page/handicapping/roh/Content/rules/5%202%20Calculation%20of%20a%20Handicap%20Index.htm
      expectd_result = 37.4
      handicap_differentials = [40.7, 42.4, 36.1, 45.9, 43.6, 45.0]
      expect(described_class.final_calc_handicap_index(handicap_differentials).first).to eq((expectd_result * 0.96).truncate(1))
    end

    it 'zero' do
      # rubocop:disable Layout/LineLength
      expect { described_class.final_calc_handicap_index([]) }.to raise_error(RuntimeError) { "Only number of handicap_differentials is 1-20 but '0' were sent" }
      # rubocop:enable Layout/LineLength
    end

    it 'twenty-one' do
      # rubocop:disable Layout/LineLength
      expect { described_class.final_calc_handicap_index(handicap_differentials.first(21)) }.to raise_error(RuntimeError) { "Only number of handicap_differentials is 1-20 but '21' were sent" }
      # rubocop:enable Layout/LineLength
    end
  end

  describe 'Course Handicap' do
    it 'course_handicap' do
      tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Blue])
      expect(tee.calc_course_handicap(36)).to eq(37)
    end
  end

  describe 'calc_course_handicap' do
    it 'calc_course_handicap avg slope rating' do
      expect(described_class.calc_course_handicap(55, 113, 72, 72)).to eq(55)
      # check rounding is called
      expect(described_class.calc_course_handicap(55.4, 113, 72, 72)).to eq(55)
      expect(described_class.calc_course_handicap(55.5, 113, 72, 72)).to eq(56)
    end

    it 'calc_course_handicap hard' do
      expect(described_class.calc_course_handicap(20, 127, 82, 72)).to eq(30)
    end

    it 'calc_course_handicap easy' do
      expect(described_class.calc_course_handicap(20, 110, 60, 72)).to eq(-12)
    end
  end
end
