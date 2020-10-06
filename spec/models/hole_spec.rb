# frozen_string_literal: true

require 'rails_helper'

describe Hole, type: :model do
  describe 'basic creation' do
    it 'default values' do
      hole = Hole.new(number: 5, par: 6, hdcp: 7)
      expect(hole.number).to eq(5)
      expect(hole.par).to eq(6)
      expect(hole.hdcp).to eq(7)
    end
  end
end
