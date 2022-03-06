# frozen_string_literal: true

require 'support/round_info_spec_helper'

describe RoundInfo, type: :model do
  include(RoundInfoSpecHelper)
  before do
    @round18 = RoundInfoSpecHelper.create_round18(0, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18_2)
    @round_info = RoundInfo.new(@round18, 18)
  end
  it 'delegates: tee, date' do
    expect(@round_info.tee).to eq(@round18.tee)
  end
  it 'include?' do
    @round2 = RoundInfoSpecHelper.create_round18(0, 0, RoundInfoSpecHelper::ROUND_SCORE_INFO_BLACK18_2, 113, 71)
    expect(@round_info.includes?(@round18)).to eq(true)
    expect(@round_info.includes?(@round2)).to eq(false)
  end
  it 'calc_score_differential' do
    total_score_differential = @round_info.calc_score_differential(50)
    # @round_info.print_hi_info([total_score_differential])
    expect(total_score_differential).to eq(45.9)
  end
  it 'debug info' do
    @round_info.calc_score_differential(50)
    expect(@round_info.round).to eq(@round18)
    expect(@round_info.number_of_holes).to eq(18)
    expect(@round_info.sd).to eq(45.9)
    expect(@round_info.par).to eq(71)
    expect(@round_info.adjusted_score).to eq(128)
    expect(@round_info.unadjusted_score).to eq(129)
    expect(@round_info.course_handicap).to eq(62.0)
    expect(@round_info.slope).to eq(139.0)
    expect(format('%.1f', @round_info.rating)).to eq(format('%.1f', 71.6))
  end
end
