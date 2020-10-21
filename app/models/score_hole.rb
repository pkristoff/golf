# frozen_string_literal: true

# ScoreHole
#
class ScoreHole < ApplicationRecord
  belongs_to :score, dependent: :destroy
  belongs_to :hole
end
