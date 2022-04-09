# frozen_string_literal: true

describe DbStuff, type: :lib do
  before(:all) do
    @expected_class_list = [
      Account,
      Course,
      Address,
      Hole,
      Round,
      Score,
      ScoreHole,
      Tee
    ]
  end
  it 'list of db tables in order' do
    expect(@expected_class_list).to eq(DbStuff.db_tables)
  end

  describe 'clear_db' do
    before(:all) do
    end
    it 'db already empty' do
      expect_db_sizes
      DbStuff.clear_db
      expect_db_sizes
    end
    it 'db not empty and gets cleared' do
      Account.create(name: 'Paul', handicap_index: 0.0)
      FactoryBot.create(:round)
      expect_db_sizes([1, 1, 1, 72, 1, 18, 18, 4])
      DbStuff.clear_db
      expect_db_sizes
    end
  end

  private

  def expect_db_sizes(expected_size = [0, 0, 0, 0, 0, 0, 0, 0])
    DbStuff.db_tables.each_with_index do |clazz, index|
      actual_size = clazz.all.size
      expect(actual_size).to eq(expected_size[index]),
                             "DB size mismatch: clazz='#{clazz}' expected size=#{expected_size[index]} actual size=#{actual_size}"
    end
  end
end