# frozen_string_literal: true

describe RoundInfo9, type: :model do
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
    @round1 = RoundInfoSpecHelper.create_round9(113, 71, 0, 0, @round_score_info_black9)
    @round2 = RoundInfoSpecHelper.create_round9(113, 71, 1, 1, @round_score_info_black9)
  end
  it 'delegates: tee, date' do
    round_info9 = RoundInfo9.new(@round1, @round2, 9)
    expect(round_info9.tee).to eq(@round2.tee)
  end
end
