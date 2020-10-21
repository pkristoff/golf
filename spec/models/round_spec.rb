# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe Round, type: :model do
  it 'create factory' do
    round = FactoryBot.create(:round)
    expect(round).to be_truthy
    expect(round.date).to eq(Time.zone.today)
    expect_score(round, TeeHoleInfo::BLACK_SCORE_INFO)
    expect(round.tee.color).to eq('Black')
  end
end

def expect_score(round, score_info)
  score_info.each do |info|
    hole_number = info[0]
    next if hole_number.nil?

    strokes = info[1]
    putts = info[2]
    score = round.score(hole_number)
    expect(score.round).to eql(round)
    expect(score.hole_number).to eq(hole_number)
    expect(score.hole.number).to eq(hole_number)
    expect(score.hole.number).to eq(hole_number)
    expect(score.strokes).to eq(strokes)
    expect(score.putts).to eq(putts)
  end
end
