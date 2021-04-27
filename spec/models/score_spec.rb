# frozen_string_literal: true

require 'rails_helper'

describe Score, type: :model do
  it 'should create a Score' do
    score = FactoryBot.create(:score)
    expect(score.strokes).to eq(4)
    expect(score.putts).to eq(2)
    expect(score.penalties).to eq('W')
  end
end
