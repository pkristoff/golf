# frozen_string_literal: true

# PerformanceCourse
#
class PerformanceCourse
  attr_accessor :average_strokes, :average_putts

  # creates a PerformanceCourse
  #
  # === Parameters:
  #
  # * <tt>:rounds</tt> for a tee
  # * <tt>:number_of_holes</tt> for tee
  #
  # === Returns:
  #
  # * <tt>PerformanceCourse</tt>
  #
  def initialize(rounds, number_of_holes)
    @rounds = rounds
    @number_of_holes = number_of_holes
  end

  # Average strokes per round for a tee
  #
  # sets & returns @average_strokes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of Number
  #
  def average_strokes_with_totals
    hole_average_strokes
  end

  # Average putts per round for a tee
  #
  # sets & returns @average_putts
  #
  # === Returns:
  #
  # * <tt>Array</tt> of Number
  #
  def average_putts_with_totals
    hole_average_putts
  end

  private

  def hole_average_putts
    average_putts = Array.new(@number_of_holes + 3, 0)
    out_total_putts = 0
    in_total_putts = 0
    @rounds.each do |round|
      round.score_holes.each_with_index do |score_hole, index|
        putts = score_hole.score.putts
        out_total_putts += putts if index < 9
        in_total_putts += putts if index >= 9
        average_putts[index] += putts
      end
    end
    return average_putts if @rounds.empty?

    in_total_putts /= @rounds.size
    out_total_putts /= @rounds.size
    total_putts = in_total_putts + out_total_putts
    average_putts = average_putts.map { |tot| tot / @rounds.size }

    @average_putts = (average_putts[0..8] << out_total_putts).concat(average_putts[9..17]) << in_total_putts << total_putts
  end

  def hole_average_strokes
    average_strokes = Array.new(@number_of_holes + 3, 0)
    out_total_strokes = 0
    in_total_strokes = 0
    @rounds.each do |round|
      round.score_holes.each_with_index do |score_hole, index|
        strokes = score_hole.score.strokes
        out_total_strokes += strokes if index < 9
        in_total_strokes += strokes if index >= 9
        average_strokes[index] += strokes
      end
    end
    return average_strokes if @rounds.empty?

    in_total_strokes /= @rounds.size
    out_total_strokes /= @rounds.size
    total_strokes = in_total_strokes + out_total_strokes
    average_strokes = average_strokes.map { |tot| tot / @rounds.size }
    # rubocop:disable Layout/LineLength
    @average_strokes = (average_strokes[0..8] << out_total_strokes).concat(average_strokes[9..17]) << in_total_strokes << total_strokes
    # rubocop:enable Layout/LineLength
  end
end
