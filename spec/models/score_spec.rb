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
  describe 'golf_term' do
    it 'should return Albatross' do
      expect(Score.golf_term(5, 2)).to eq('Albatross')
      expect(Score.golf_term(4, 1)).to eq('Albatross')
    end
    it 'should return Eagle' do
      expect(Score.golf_term(5, 3)).to eq('Eagle')
      expect(Score.golf_term(4, 2)).to eq('Eagle')
      expect(Score.golf_term(3, 1)).to eq('Eagle')
    end
    it 'should return Birdie' do
      expect(Score.golf_term(5, 4)).to eq('Birdie')
      expect(Score.golf_term(4, 3)).to eq('Birdie')
      expect(Score.golf_term(3, 2)).to eq('Birdie')
    end
    it 'should return Par' do
      expect(Score.golf_term(5, 5)).to eq('Par')
      expect(Score.golf_term(4, 4)).to eq('Par')
      expect(Score.golf_term(3, 3)).to eq('Par')
    end
    it 'should return Double-bogey' do
      expect(Score.golf_term(5, 7)).to eq('Double-bogey')
      expect(Score.golf_term(4, 6)).to eq('Double-bogey')
      expect(Score.golf_term(3, 5)).to eq('Double-bogey')
    end
    it 'should return Triple-bogey' do
      expect(Score.golf_term(5, 8)).to eq('Triple-bogey')
      expect(Score.golf_term(4, 7)).to eq('Triple-bogey')
      expect(Score.golf_term(3, 6)).to eq('Triple-bogey')

      expect(Score.golf_term(5, 10)).to eq('Triple-bogey')
      expect(Score.golf_term(5, 1)).to eq('Triple-bogey')
    end
  end
end
