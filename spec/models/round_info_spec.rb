# frozen_string_literal: true

require 'support/round_info_spec_helper'

describe RoundInfo, type: :model do
  include(RoundInfoSpecHelper)
  before do
    @round_score_info_black = [
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
    @round18 = RoundInfoSpecHelper.create_round18(113, 71, 0, 0, @round_score_info_black)
    @round_info = RoundInfo.new(@round18, 18)
  end
  it 'delegates: tee, date' do
    expect(@round_info.tee).to eq(@round18.tee)
  end
  it 'include?' do
    @round2 = RoundInfoSpecHelper.create_round18(113, 71, 0, 0, @round_score_info_black)
    expect(@round_info.includes?(@round18)).to eq(true)
    expect(@round_info.includes?(@round2)).to eq(false)
  end
  it 'calc_score_differential' do
    total_score_differential = @round_info.calc_score_differential(50)
    # @round_info.print_hi_info([total_score_differential])
    expect(total_score_differential).to eq(57)
  end
  it 'debug info' do
    @round_info.calc_score_differential(50)
    expect(@round_info.round).to eq(@round18)
    expect(@round_info.number_of_holes).to eq(18)
    expect(@round_info.sd).to eq(57.0)
    expect(@round_info.par).to eq(71)
    expect(@round_info.adjusted_score).to eq(128)
    expect(@round_info.unadjusted_score).to eq(129)
    expect(@round_info.course_handicap).to eq(50.0)
    expect(@round_info.slope).to eq(113.0)
    expect(@round_info.rating).to eq(71.0)
  end
end
