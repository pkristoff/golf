# frozen_string_literal: true

require 'rails_helper'
require 'support/round_info_spec_helper'

describe Account, type: :model do
  include(RoundInfoSpecHelper)
  before do
    @account = Account.create(name: 'Paul', handicap_index: 0.0)
  end
  describe 'handicap_index' do
    describe 'calc_handicap_index' do
      before do
      end
      it '0 rounds' do
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(0.0)
      end
      it '1 rounds' do
        @round = RoundInfoSpecHelper.create_round18(5, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(9.6)
      end
      it '2 rounds different tee' do
        expected_hi = create_two_rounds
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(expected_hi)
      end
      it '3 rounds different course' do
        @round = RoundInfoSpecHelper.create_round18(3, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
        @round2 = RoundInfoSpecHelper.create_round18(4, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 79.0)
        @round3 = RoundInfoSpecHelper.create_round18(5, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 110, 67)
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(7.6)
      end
      it '5 rounds different course' do
        [[139, 79, 1], [113, 79, 1], [139, 79, 3], [139, 79, 3], [139, 79, 3]].each_with_index do |info, index|
          slope = info[0]
          rating = info[1]
          score_increase = info[2]
          RoundInfoSpecHelper.create_round18(index + 6, score_increase, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18,
                                             slope, rating)
        end
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(7.7)
      end
      it '6 rounds different course' do
        expected_hi = create_six_rounds
        account = Account.find_by(id: @account.id)
        account.calc_handicap_index
        expect(account.handicap_index).to eq(expected_hi)
      end
    end
    describe 'max_hdcp_score' do
      before do
        @strokes = 10
        @par = 4
      end
      describe '1..9' do
        before do
          @expected_strokes = 6
        end
        it '1' do
          expect(Tee.calc_adjusted_score(1, @strokes, @par)).to eq(@expected_strokes)
        end
        it '9' do
          expect(Tee.calc_adjusted_score(1, @strokes, @par)).to eq(@expected_strokes)
        end
      end
      describe '10..19' do
        before do
          @expected_strokes = 7
        end
        it '10' do
          expect(Tee.calc_adjusted_score(10, @strokes, @par)).to eq(@expected_strokes)
        end
        it '19' do
          expect(Tee.calc_adjusted_score(19, @strokes, @par)).to eq(@expected_strokes)
        end
      end
      describe '20..29' do
        before do
          @expected_strokes = 8
        end
        it '20' do
          expect(Tee.calc_adjusted_score(20, @strokes, @par)).to eq(@expected_strokes)
        end
        it '29' do
          expect(Tee.calc_adjusted_score(29, @strokes, @par)).to eq(@expected_strokes)
        end
      end
      describe '30..39' do
        before do
          @expected_strokes = 9
        end
        it '30' do
          expect(Tee.calc_adjusted_score(30, @strokes, @par)).to eq(@expected_strokes)
        end
        it '39' do
          expect(Tee.calc_adjusted_score(39, @strokes, @par)).to eq(@expected_strokes)
        end
      end
      describe '40..54' do
        before do
          @expected_strokes = 10
        end
        it '40' do
          expect(Tee.calc_adjusted_score(40, @strokes, @par)).to eq(@expected_strokes)
        end
        it '54' do
          expect(Tee.calc_adjusted_score(54, @strokes, @par)).to eq(@expected_strokes)
        end
      end
    end
    describe 'find_rounds' do
      before do
      end
      describe 'find_9_hole_round_infos_with_matching9' do
        it '0 rounds' do
          expect(Account.find_9_hole_round_infos_with_matching9.size).to eq(0)
        end
        it '1 rounds' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          expect(Account.find_9_hole_round_infos_with_matching9.size).to eq(0)
          rounds = Round.all
          expect(rounds.size).to eq(1)
          expect(rounds.first.tee.course.number_of_holes).to eq(9)
        end
        it '2 rounds diff date' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          RoundInfoSpecHelper.create_round9(2, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          expect(Account.find_9_hole_round_infos_with_matching9.size).to eq(0)
          rounds = Round.all
          expect(rounds.size).to eq(2)
          expect(rounds.first.tee.course.number_of_holes).to eq(9)
          expect(rounds.second.tee.course.number_of_holes).to eq(9)
        end
        it '2 rounds same date' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          all_round_info_sorted = Account.find_9_hole_round_infos_with_matching9
          expect(all_round_info_sorted.size).to eq(1)
          rounds = Round.all
          expect(rounds.size).to eq(2)
          expect(rounds.first.tee.course.number_of_holes).to eq(9)
          expect(rounds.second.tee.course.number_of_holes).to eq(9)
        end
        it '3 rounds same date' do
          round1 = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round2 = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round3 = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)

          all_round_info_sorted = Account.find_9_hole_round_infos_with_matching9.sort_by(&:date)

          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round1)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round2)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round3)).to eq(false)
        end
        it '3 rounds 2 with same date' do
          round1 = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round2 = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round3 = RoundInfoSpecHelper.create_round9(2, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          all_round_info_sorted = Account.find_9_hole_round_infos_with_matching9.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round1)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round2)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round3)).to eq(false)
        end
      end
      describe 'all_round_infos' do
        it 'no rounds' do
          expect(Account.all_round_infos.size).to eq(0)
        end
        it 'one 9-hole round' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          expect(Account.all_round_infos.size).to eq(0)
        end
        it 'one 9-hole round one 18-hole' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round18 = RoundInfoSpecHelper.create_round18(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 71)
          all_round_info_sorted = Account.all_round_infos.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round18)).to eq(true)
        end
        it 'two 9-hole rounds diff date one 18-hole' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          RoundInfoSpecHelper.create_round9(3, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round18 = RoundInfoSpecHelper.create_round18(2, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 71)
          all_round_info_sorted = Account.all_round_infos.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(1)
          expect(all_round_info_sorted.first.includes?(round18)).to eq(true)
        end
        it 'two 9-hole rounds same date one 18-hole' do
          round9_a = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round9_b = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round18 = RoundInfoSpecHelper.create_round18(0, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 71)
          all_round_info_sorted = Account.all_round_infos.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(2)
          expect(all_round_info_sorted.first.includes?(round9_a)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_b)).to eq(true)
          expect(all_round_info_sorted.second.includes?(round18)).to eq(true)
        end
        it 'three 9-hole rounds same date one 18-hole' do
          round9_a = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round9_b = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round9_c = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round18 = RoundInfoSpecHelper.create_round18(0, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 71)
          all_round_info_sorted = Account.all_round_infos.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(2)
          expect(all_round_info_sorted.first.includes?(round9_a)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_b)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_c)).to eq(false)
          expect(all_round_info_sorted.second.includes?(round18)).to eq(true)
        end
        it 'four 9-hole rounds same date around one 18-hole' do
          round9_a = RoundInfoSpecHelper.create_round9(3, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round9_b = RoundInfoSpecHelper.create_round9(3, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round9_c = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round9_d = RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          round18 = RoundInfoSpecHelper.create_round18(2, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 71)
          all_round_info_sorted = Account.all_round_infos.sort_by(&:date)
          expect(all_round_info_sorted.size).to eq(3)
          expect(all_round_info_sorted.first.includes?(round9_a)).to eq(true)
          expect(all_round_info_sorted.first.includes?(round9_b)).to eq(true)
          expect(all_round_info_sorted.second.includes?(round18)).to eq(true)
          expect(all_round_info_sorted.third.includes?(round9_c)).to eq(true)
          expect(all_round_info_sorted.third.includes?(round9_d)).to eq(true)
        end
      end
      describe 'calc_handicap_index with 9 holes' do
        it '0 rounds' do
          account = Account.find_by(id: @account.id)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(0.0)
        end
        it '1 9-hole round' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          account = Account.find_by(id: @account.id)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(0.0)
        end
        it '2 9-hole round diff date' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          RoundInfoSpecHelper.create_round9(0, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 71)
          account = Account.find_by(id: @account.id)
          account.calc_handicap_index
          expect(account.handicap_index).to eq(0.0)
        end
        it '2 9-hole round same date' do
          RoundInfoSpecHelper.create_round9(1, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 35)
          RoundInfoSpecHelper.create_round9(1, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK9, 113, 35)
          account = Account.find_by(id: @account.id)
          hix, sorted_round_info_last, initial_hix, sorted_round_info, score_differentials, diffs_to_use, adjustment,
            avg, avg_adj, avg_adj96, max_hix = account.calc_handicap_index
          expect(account.handicap_index.to_f).to eq(54)

          # replace me
          expect(hix).to eq(68.1)
          expect(sorted_round_info_last.size).to eq(1)
          expect(sorted_round_info.size).to eq(1)
          expect(initial_hix).to eq(50)
          expect(score_differentials.size).to eq(1)
          expect(score_differentials[0]).to eq(75.0)
          expect(diffs_to_use.size).to eq(1)
          expect(diffs_to_use[0]).to eq(75)
          expect(adjustment).to eq(4)
          expect(avg).to eq(75)
          expect(avg_adj).to eq(71)
          expect(avg_adj96).to eq(68.16)
          expect(max_hix).to eq(account.handicap_index.to_f)
        end
      end
    end
  end
  describe 'course_handicap' do
    it '1 rounds' do
      round = RoundInfoSpecHelper.create_round18(5, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
      account = Account.find_by(id: @account.id)
      expect(account.calc_course_hdcp(round)).to eq(nil)
    end
    it '2 rounds' do
      RoundInfoSpecHelper.create_round18(6, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
      round2 = RoundInfoSpecHelper.create_round18(5, 2, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
      account = Account.find_by(id: @account.id)

      course_hdcp, hix = account.calc_course_hdcp(round2)
      expect(hix).to eq(9.6)
      expect(course_hdcp).to eq(12)
      # expect(account.calc_course_hdcp(round2)).to eq(12)
    end
    it '3 rounds' do
      expected_hi = create_two_rounds
      round3 = RoundInfoSpecHelper.create_round18(0, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 110, 67)
      account = Account.find_by(id: @account.id)

      course_hdcp, hix = account.calc_course_hdcp(round3)
      expect(hix).to eq(expected_hi)
      expect(course_hdcp).to eq(6)
    end
    it '7 rounds' do
      expected_hi = create_six_rounds
      round7 = RoundInfoSpecHelper.create_round18(0, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 110, 67)
      account = Account.find_by(id: @account.id)

      course_hdcp, hix = account.calc_course_hdcp(round7)
      expect(hix).to eq(expected_hi)
      expect(course_hdcp).to eq(3)
    end
  end

  private

  def set_handicap_index(account_id, handicap)
    account = Account.find_by(id: account_id)
    account.handicap_index = handicap
    account.save!
    account
  end

  def create_two_rounds
    @round = RoundInfoSpecHelper.create_round18(3, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
    @round2 = RoundInfoSpecHelper.create_round18(4, 2, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 71.6)
    10.6
  end

  def create_six_rounds
    @round = RoundInfoSpecHelper.create_round18(3, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 139, 79)
    @round2 = RoundInfoSpecHelper.create_round18(4, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 113, 79)
    @round3 = RoundInfoSpecHelper.create_round18(5, 1, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18, 110, 67)
    [[139, 79, 3], [139, 79, 3], [139, 79, 3]].each_with_index do |info, index|
      slope = info[0]
      rating = info[1]
      score_increase = info[2]
      RoundInfoSpecHelper.create_round18(index + 6, score_increase, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18,
                                         slope, rating)
    end
    7.7
  end
end
