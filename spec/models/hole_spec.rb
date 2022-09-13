# frozen_string_literal: true

require 'rails_helper'

describe Hole, type: :model do
  describe 'basic creation' do
    it 'default values' do
      hole = described_class.new(number: 5, yardage: 87, par: 6, hdcp: 7)
      expect(hole.number).to eq(5)
      expect(hole.yardage).to eq(87)
      expect(hole.par).to eq(6)
      expect(hole.hdcp).to eq(7)
    end
  end
end
