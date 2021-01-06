# frozen_string_literal: true

# Address
#
class Address < ApplicationRecord
  validates :street_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true

  def self.basic_permitted_params
    %i[street_1 street_2 city state zip_code id]
  end
end
