require 'test_helper'

class HoleTest < ActiveSupport::TestCase
  test "Hole creation" do
    hole = Hole.new
    assert hole.number == 1
  end
end
