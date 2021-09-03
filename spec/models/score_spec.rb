# frozen_string_literal: true

require 'rails_helper'

describe Score, type: :model do
  describe 'Creation' do
    it 'should create a Score' do
      score = FactoryBot.create(:score)
      expect(score.strokes).to eq(4)
      expect(score.putts).to eq(2)
      expect(score.penalties).to eq('W')
    end
  end
  describe 'calculate_green_in_regulation' do
    it 'par=4 with 2 putts' do
      hole = Hole.new(par: 4)
      score = Score.new(strokes: 4, putts: 2)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=3 with 2 putts' do
      hole = Hole.new(par: 3)
      score = Score.new(strokes: 3, putts: 2)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=5 with 2 putts' do
      hole = Hole.new(par: 5)
      score = Score.new(strokes: 5, putts: 2)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=5 with 4 strokes 1 putts' do
      hole = Hole.new(par: 5)
      score = Score.new(strokes: 4, putts: 1)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=4 with 3 strokes 1 putts' do
      hole = Hole.new(par: 4)
      score = Score.new(strokes: 3, putts: 1)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=3 with 2 strokes 1 putts' do
      hole = Hole.new(par: 3)
      score = Score.new(strokes: 2, putts: 1)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=5 with 6 strokes 3 putts' do
      hole = Hole.new(par: 5)
      score = Score.new(strokes: 6, putts: 3)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=4 with 3 strokes 1 putts' do
      hole = Hole.new(par: 4)
      score = Score.new(strokes: 5, putts: 3)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=3 with 2 strokes 1 putts' do
      hole = Hole.new(par: 3)
      score = Score.new(strokes: 4, putts: 3)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end

    it 'par=4 with strokes=5 & putts=2' do
      hole = Hole.new(par: 4)
      score = Score.new(strokes: 5, putts: 2)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(false)
    end

    it 'par=5 with strokes=10 & putts=3' do
      hole = Hole.new(par: 5)
      score = Score.new(strokes: 10, putts: 3)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(false)
    end

    it 'par=4 with strokes=4 & putts=3' do
      hole = Hole.new(par: 4)
      score = Score.new(strokes: 5, putts: 3)
      score.calculate_green_in_regulation hole
      expect(score.green_in_regulation).to be(true)
    end
  end
end
