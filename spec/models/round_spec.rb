# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe Round, type: :model do
  before(:each) do
    @round = FactoryBot.create(:round)
  end
  it 'create factory' do
    round = @round
    expect(round).to be_truthy
    expect(round.tee.rounds.size).to eq(1)
    expect(round.tee.rounds[0]).to eq(round)
    expect(round.date).to eq(Time.zone.today)
    expect_score(round, TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO])
    expect(round.tee.color).to eq('Black')
  end
  describe 'score' do
    it 'should return nil if not found' do
      expect(@round.score(19)).to be_nil
    end
    it 'should return a Score if found' do
      score = @round.score(18)

      expect(score).to be_truthy
      expect(score.hole.number).to eq(18)
    end
  end
  describe 'tee' do
    it 'should return a Tee if found' do
      tee = @round.tee
      expect(tee).to be_truthy
      expect(tee.color).to eq('Black')
    end
  end
  describe 'add_score' do
    it 'should add a score for hole' do
    end
    it 'should error if score for hole number already exists' do
      hole = @round.tee.sorted_holes.first
      expect { @round.add_score(hole, 5, 5, 'OBW') }.to raise_error("score for hole number:#{hole.number} already exists")
    end
    it 'should error if score for hole of another tee' do
      course = FactoryBot.create(:course, name: 'George2')
      tee1 = course.tee('Black')
      hole1 = tee1.sorted_holes.first
      tee2 = course.tee('White')
      hole2 = tee2.sorted_holes.second
      round1 = Round.new(tee: tee1)
      round1.add_score(hole1, 5, 5, '')
      # rubocop:disable Layout/LineLength
      expect { round1.add_score(hole2, 6, 2, 'OBW') }.to raise_error("Hole from a different tee current tee: '#{tee1.color}' adding hole from tee '#{tee2.color}'")
      # rubocop:enable Layout/LineLength
    end
    it 'should error if score for hole of another course' do
      course1 = FactoryBot.create(:course, name: 'George2')
      tee1 = course1.tee('Black')
      hole1 = tee1.sorted_holes.first
      course2 = FactoryBot.create(:course, name: 'George3')
      tee2 = course2.tee('Black')
      hole2 = tee2.sorted_holes.second
      round1 = Round.new(tee: hole1.tee)
      round1.add_score(hole1, 5, 5, '')
      # rubocop:disable Layout/LineLength
      expect { round1.add_score(hole2, 6, 2, 'OBW') }.to raise_error("Hole from a different course current course: '#{course1.name}' adding hole from '#{course2.name}'")
      # rubocop:enable Layout/LineLength
    end
  end
  describe 'self.rounds' do
    it 'should return an empty array if none is found' do
      course = Course.create(name: 'foo')
      expect(Round.rounds(course)).to be_empty
    end
    it 'should return an array of Round if found' do
      course = @round.course
      rounds = Round.rounds(course)
      expect(rounds).not_to be_empty
      expect(rounds.size).to eq(1)
      expect(rounds[0].id).to eq(@round.id)
    end
  end
  describe 'destroy' do
    it 'should remove Round and scores used by Round, but not tee, course' do
      expect(Round.all.size).to eq(1)
      expect(Score.all.size).to eq(18)
      expect(Course.all.size).to eq(1)
      expect(Tee.all.size).to eq(4)
      expect(Hole.all.size).to eq(72)
      @round.destroy
      expect(Round.all.size).to eq(0)
      expect(Score.all.size).to eq(0)
      expect(Course.all.size).to eq(1)
      expect(Tee.all.size).to eq(4)
      expect(Hole.all.size).to eq(72)
    end
  end
  describe 'next_score' do
    it 'should return the score for hole two given score for hole 1' do
      ssh = @round.sorted_score_holes
      expect(@round.next_score(ssh[0].score)).to eq(ssh[1].score)
    end
    it 'should return the score for hole ten given score for hole 9' do
      ssh = @round.sorted_score_holes
      expect(@round.next_score(ssh[8].score)).to eq(ssh[9].score)
    end
    it 'should return the score for hole ten given score for hole 9' do
      ssh = @round.sorted_score_holes
      expect(@round.next_score(ssh[17].score)).to eq(ssh[0].score)
    end
  end
end

# Checks whether round has right strokes & putts
#
# === Parameters:
#
# * <tt>:round</tt> Round
# * <tt>:score_info</tt> Array of Array [hole_number, strokes, putts]
#
def expect_score(round, score_info)
  score_info.each do |info|
    hole_number = info[0]
    next if hole_number.nil?

    strokes = info[1]
    putts = info[2]
    score = round.score(hole_number)
    expect(score.round).to eql(round)
    expect(score.hole.number).to eq(hole_number)
    expect(score.hole.number).to eq(hole_number)
    expect(score.strokes).to eq(strokes)
    expect(score.putts).to eq(putts)
  end
end
