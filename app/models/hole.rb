# frozen_string_literal: true

# A Hole
class Hole < ApplicationRecord
  belongs_to(:tee)
  has_many :score_holes, dependent: :destroy
  has_many :scores, through: :score_holes, dependent: :destroy
end
