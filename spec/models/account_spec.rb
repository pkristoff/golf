# frozen_string_literal: true

require 'rails_helper'

describe Account, type: :model do
  describe 'handicap_index' do
    before do
      @account = Account.create(name: 'Paul', handicap_index: 0.0)
    end
    describe 'calc_handicap_index' do
      before do
        @round_score_info_black18 = [
          # [hole, strokes, putts, penalties, Fairways, strokes inside 80]
          [1, 4, 2],
          [2, 4, 2],
          [3, 3, 2],
          [4, 4, 2],
          [5, 4, 2],
          [6, 4, 2],
          [7, 3, 2],
          [8, 4, 2],
          [9, 5, 2],
          [nil, 35, 18],
          [10, 4, 2],
          [11, 3, 2],
          [12, 5, 2],
          [13, 4, 2],
          [14, 4, 2],
          [15, 4, 2],
          [16, 5, 2],
          [17, 3, 2],
          [18, 4, 2],
          [nil, 36, 18],
          [nil, 71, 36]
        ]
      end
      it '0 rounds' do
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(0.0)
      end
      it '1 rounds' do
        @round = FactoryBot.create(:round,
                                   date: Time.zone.now.to_date - 5,
                                   round_score_info: generate_round_scores(@round_score_info_black18, 1))
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(9.6)
      end
      it '2 rounds different tee' do
        @round = FactoryBot.create(:round, date: Time.zone.now.to_date - 3, round_score_info: @round_score_info_black18)
        @round2 = FactoryBot.create(:round,
                                    tee: @round.tee,
                                    date: Time.zone.now.to_date - 4,
                                    round_score_info: generate_round_scores(@round_score_info_black18, 1))
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(-3.3)
      end
      it '3 rounds different course' do
        @round = FactoryBot.create(:round,
                                   date: Time.zone.now.to_date - 3,
                                   round_score_info: generate_round_scores(@round_score_info_black18, 1))
        @round2 = create_round18(113, 79, 4, 1)
        @round3 = create_round18(110, 67, 5, 1)
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(7.6)
      end
      it '5 rounds different course' do
        [[139, 79, 1], [113, 79, 1], [139, 79, 3], [139, 79, 3], [139, 79, 3]].each_with_index do |info, index|
          slope = info[0]
          rating = info[1]
          score_increase = info[2]
          create_round18(slope, rating, index + 6, score_increase)
        end
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(7.7)
      end
      it '6 rounds different course' do
        @round = create_round18(139, 79, 3, 1)
        @round2 = create_round18(113, 79, 4, 1)
        @round3 = create_round18(110, 67, 5, 1)
        [[139, 79, 3], [139, 79, 3], [139, 79, 3]].each_with_index do |info, index|
          slope = info[0]
          rating = info[1]
          score_increase = info[2]
          create_round18(slope, rating, index + 6, score_increase)
        end
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(7.7)
      end
    end
    describe 'max_hdcp_score' do
      before do
        @round_score_info_black18 = [
          # [hole, strokes, putts]
          # 0..9
          [1, 6, 2], # 4
          [2, 6, 2], # 4
          [3, 5, 2], # 3
          # 10..19
          [4, 8, 2], # 4
          [5, 8, 2], # 4
          [6, 8, 2], # 4
          # 20..29
          [7, 9, 2], # 3
          [8, 9, 2], # 4
          [9, 9, 2], # 5

          [nil, 68, 18],

          # 30..39
          [10, 10, 2], # 4
          [11, 10, 2], # 3
          [12, 10, 2], # 5
          # else
          [13, 11, 2], # 4
          [14, 4, 2], # 4
          [15, 4, 2], # 4
          [16, 5, 2], # 5
          [17, 3, 2], # 3
          [18, 4, 2], # 4
          [nil, 61, 18],
          [nil, 129, 36]
        ]
        create_round18(113, 71, 1, 0)
      end
      describe '1..9' do
        before do
          @expected_handicap = 21.1
        end
        it '1' do
          account = set_handicap_index(@account.id, 1)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
        it '9' do
          account = set_handicap_index(@account.id, 9)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
      end
      describe '10..19' do
        before do
          @expected_handicap = 30.7
        end
        it '10' do
          account = set_handicap_index(@account.id, 10)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
        it '19' do
          account = set_handicap_index(@account.id, 19)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
      end
      describe '20..29' do
        before do
          @expected_handicap = 40.3
        end
        it '20' do
          account = set_handicap_index(@account.id, 20)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
        it '29' do
          account = set_handicap_index(@account.id, 29)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
      end
      describe '30..39' do
        before do
          @expected_handicap = 47
        end
        it '30' do
          account = set_handicap_index(@account.id, 30)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
        it '39' do
          account = set_handicap_index(@account.id, 39)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
      end
      describe '40..54' do
        before do
          @expected_handicap = 50.8
        end
        it '40' do
          account = set_handicap_index(@account.id, 40)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
        it '54' do
          account = set_handicap_index(@account.id, 54)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(@expected_handicap)
        end
      end
    end
    describe 'find_rounds' do
      before do
        @round_score_info_black18 = [
          # [hole, strokes, putts]
          # 0..9
          [1, 6, 2], # 4
          [2, 6, 2], # 4
          [3, 5, 2], # 3
          # 10..19
          [4, 8, 2], # 4
          [5, 8, 2], # 4
          [6, 8, 2], # 4
          # 20..29
          [7, 9, 2], # 3
          [8, 9, 2], # 4
          [9, 9, 2], # 5

          [nil, 68, 18],

          # 30..39
          [10, 10, 2], # 4
          [11, 10, 2], # 3
          [12, 10, 2], # 5
          # else
          [13, 11, 2], # 4
          [14, 4, 2], # 4
          [15, 4, 2], # 4
          [16, 5, 2], # 5
          [17, 3, 2], # 3
          [18, 4, 2], # 4
          [nil, 61, 18],
          [nil, 129, 36]
        ]
        @round_score_info_black9 = [
          # [hole, strokes, putts]
          # 0..9
          [1, 6, 2], # 4
          [2, 6, 2], # 4
          [3, 5, 2], # 3
          # 10..19
          [4, 8, 2], # 4
          [5, 8, 2], # 4
          [6, 8, 2], # 4
          # 20..29
          [7, 9, 2], # 3
          [8, 9, 2], # 4
          [9, 9, 2], # 5

          [nil, 68, 18],

          # 30..39
          [10, 10, 2], # 4
          [11, 10, 2], # 3
          [12, 10, 2], # 5
          # else
          [13, 11, 2], # 4
          [14, 4, 2], # 4
          [15, 4, 2], # 4
          [16, 5, 2], # 5
          [17, 3, 2], # 3
          [18, 4, 2], # 4
          [nil, 61, 18],
          [nil, 129, 36]
        ]
      end
      describe 'find_9_hole_rounds_with_matching18' do
        it 'no rounds' do
          expect(Account.find_9_hole_rounds_with_matching18.size).to eq(0)
        end
        it '1 rounds' do
          create_round9(113, 71, 1, 0)
          expect(Account.find_9_hole_rounds_with_matching18.size).to eq(0)
          rounds = Round.all
          expect(rounds.size).to eq(1)
          expect(rounds.first.tee.course.number_of_holes).to eq(9)
        end
        it '2 rounds diff date' do
          create_round9(113, 71, 1, 0)
          create_round9(113, 71, 2, 0)
          expect(Account.find_9_hole_rounds_with_matching18.size).to eq(0)
          rounds = Round.all
          expect(rounds.size).to eq(2)
          expect(rounds.first.tee.course.number_of_holes).to eq(9)
          expect(rounds.second.tee.course.number_of_holes).to eq(9)
        end
        it '2 rounds same date' do
          create_round9(113, 71, 1, 0)
          create_round9(113, 71, 1, 0)
          all_round_info_sorted = Account.find_9_hole_rounds_with_matching18
          expect(all_round_info_sorted.size).to eq(1)
          rounds = Round.all
          expect(rounds.size).to eq(2)
          expect(rounds.first.tee.course.number_of_holes).to eq(9)
          expect(rounds.second.tee.course.number_of_holes).to eq(9)
        end
        it '3 rounds same date' do
          round1 = create_round9(113, 71, 1, 0)
          round2 = create_round9(113, 71, 1, 0)
          round3 = create_round9(113, 71, 1, 0)

          all_round_info_sorted = Account.find_9_hole_rounds_with_matching18.sort_by(&:date)

          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round1)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round2)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round3)).to eq(false)
        end
        it '3 rounds 2 with same date' do
          round1 = create_round9(113, 71, 1, 0)
          round2 = create_round9(113, 71, 1, 0)
          round3 = create_round9(113, 71, 2, 0)
          all_round_info_sorted = Account.find_9_hole_rounds_with_matching18.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round1)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round2)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round3)).to eq(false)
        end
      end
      describe 'find_all_rounds' do
        it 'no rounds' do
          expect(Account.find_all_rounds.size).to eq(0)
        end
        it 'one 9-hole round' do
          create_round9(113, 71, 1, 0)
          expect(Account.find_all_rounds.size).to eq(0)
        end
        it 'one 9-hole round one 18-hole' do
          create_round9(113, 71, 1, 0)
          round18 = create_round18(113, 71, 1, 0)
          all_round_info_sorted = Account.find_all_rounds.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round18)).to eq(true)
        end
        it 'two 9-hole rounds diff date one 18-hole' do
          create_round9(113, 71, 1, 0)
          create_round9(113, 71, 3, 0)
          round18 = create_round18(113, 71, 2, 0)
          all_round_info_sorted = Account.find_all_rounds.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round18)).to eq(true)
        end
        it 'two 9-hole rounds same date one 18-hole' do
          round9_a = create_round9(113, 71, 1, 0)
          round9_b = create_round9(113, 71, 1, 0)
          round18 = create_round18(113, 71, 0, 0)
          all_round_info_sorted = Account.find_all_rounds.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(2)
          expect(all_round_info_sorted.first.includes?(round9_a)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_b)).to eq(true)
          expect(all_round_info_sorted.second.includes?(round18)).to eq(true)
        end
        it 'three 9-hole rounds same date one 18-hole' do
          round9_a = create_round9(113, 71, 1, 0)
          round9_b = create_round9(113, 71, 1, 0)
          round9_c = create_round9(113, 71, 1, 0)
          round18 = create_round18(113, 71, 0, 0)
          all_round_info_sorted = Account.find_all_rounds.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(2)
          expect(all_round_info_sorted.first.includes?(round9_a)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_b)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_c)).to eq(false)
          expect(all_round_info_sorted.second.includes?(round18)).to eq(true)
        end
        it 'four 9-hole rounds same date around one 18-hole' do
          round9_a = create_round9(113, 71, 3, 0)
          round9_b = create_round9(113, 71, 3, 0)
          round9_c = create_round9(113, 71, 1, 0)
          round9_d = create_round9(113, 71, 1, 0)
          round18 = create_round18(113, 71, 2, 0)
          all_round_info_sorted = Account.find_all_rounds.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(3)
          expect(all_round_info_sorted.first.includes?(round9_a)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_b)).to eq(true)
          expect(all_round_info_sorted.second.includes?(round18)).to eq(true)
          expect(all_round_info_sorted.third.includes?(round9_c)).to eq(true)
          expect(all_round_info_sorted.third.includes?(round9_d)).to eq(true)
        end
      end
    end
  end

  private

  def set_handicap_index(account_id, handicap)
    account = Account.find_by(id: account_id)
    account.handicap_index = handicap
    account.save!
    account
  end

  def create_round18(slope, rating, today_offset, score_increase)
    round = FactoryBot.create(:round,
                              date: Time.zone.now.to_date - today_offset,
                              round_score_info: generate_round_scores(@round_score_info_black18, score_increase))
    round.tee.slope = slope
    round.tee.rating = rating
    round.tee.save!
    round
  end

  def create_round9(slope, rating, today_offset, score_increase, _time_offset = 0)
    now = Time.zone.now
    round = FactoryBot.create(:round,
                              date: now.to_date - today_offset,
                              round_score_info: generate_round_scores(@round_score_info_black9, score_increase))

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

  def generate_round_scores(base, increase)
    gen_round = []
    base.map do |entry|
      gen_round.push([entry[0], entry[1] + increase, entry[2]]) unless entry[0].nil?
      gen_round.push([entry[0], entry[1] + (increase * 9), entry[2]]) if entry[0].nil? && (entry[1] < 70)
      gen_round.push([entry[0], entry[1] + (increase * 18), entry[2]]) if entry[0].nil? && entry[1] > 70
    end
    gen_round
  end
end
