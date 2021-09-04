# frozen_string_literal: true

# Address
#
class Address < ApplicationRecord
  validates :street1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true

  # legal attributes for Address
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def self.basic_permitted_params
    %i[street1 street2 city state zip_code id]
  end
end
