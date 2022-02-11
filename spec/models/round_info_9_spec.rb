# frozen_string_literal: true

require 'rails_helper'
require 'support/round_info_spec_helper'

describe RoundInfo9, type: :model do
  include(RoundInfoSpecHelper)
  before do
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
    @round1 = RoundInfoSpecHelper.create_round9(113, 27, 0, 0, @round_score_info_black9)
    @round2 = RoundInfoSpecHelper.create_round9(113, 27, 1, 1, @round_score_info_black9)
    @round_info9 = RoundInfo9.new(@round1, @round2, 9)
  end
  it 'delegates: tee, date' do
    expect(@round_info9.tee).to eq(@round2.tee)
    expect(@round_info9.date).to eq(@round2.date)
  end
  it 'include?' do
    expect(@round_info9.includes?(@round1)).to eq(true)
    expect(@round_info9.includes?(@round2)).to eq(true)
    @round3 = RoundInfoSpecHelper.create_round9(113, 27, 1, 1, @round_score_info_black9)
    expect(@round_info9.includes?(@round3)).to eq(false)
  end
  it 'calc_score_differential' do
    total_score_differential = @round_info9.calc_score_differential(50)
    # @round_info9.print_hi_info([total_score_differential])
    expect(total_score_differential).to eq(91)
  end
  it 'debug info' do
    @round_info9.calc_score_differential(50)
    expect(@round_info9.round).to eq(@round1)
    expect(@round_info9.number_of_holes).to eq(9)
    expect(@round_info9.sd).to eq(41.0)
    expect(@round_info9.par).to eq(35)
    expect(@round_info9.adjusted_score).to eq(68)
    expect(@round_info9.unadjusted_score).to eq(68)
    expect(@round_info9.course_handicap).to eq(42.0)
    expect(@round_info9.slope).to eq(113.0)
    expect(@round_info9.rating).to eq(27.0)

    expect(@round_info9.round2).to eq(@round2)
    expect(@round_info9.sd2).to eq(50.0)
    expect(@round_info9.par2).to eq(35)
    expect(@round_info9.adjusted_score2).to eq(77)
    expect(@round_info9.unadjusted_score2).to eq(77)
    expect(@round_info9.course_handicap2).to eq(42.0)
    expect(@round_info9.slope2).to eq(113.0)
    expect(@round_info9.rating2).to eq(27.0)
  end
end
