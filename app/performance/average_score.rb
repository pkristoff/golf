# frozen_string_literal: true

# Holder of average info related to score
#
class AverageScore
  attr_accessor :hole, :strokes, :putts, :strokes_under80, :max, :min

  # Make initial AverageScore
  #
  # === Parameters:
  #
  # * <tt>:hole</tt> Hole
  # * <tt>:strokes</tt> number of strokes
  # * <tt>:putts</tt>
  # * <tt>:strokes_under80</tt>
  #
  # === Returns:
  #
  # * <tt>AverageScore</tt>
  #
  def initialize(hole, strokes, putts, strokes_under80)
    @hole = hole
    @strokes = strokes
    @putts = putts
    @strokes_under80 = strokes_under80
    super()
  end
end
