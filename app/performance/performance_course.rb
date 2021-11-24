# frozen_string_literal: true

# PerformanceCourse
#
class PerformanceCourse
  attr_accessor :average_holes, :tee

  # creates a PerformanceCourse
  #
  # === Parameters:
  #
  # * <tt>:tee</tt>tee
  # * <tt>:number_of_holes</tt> for tee
  #
  # === Returns:
  #
  # * <tt>PerformanceCourse</tt>
  #
  def initialize(tee, number_of_holes)
    @tee = tee
    @number_of_holes = number_of_holes
    initialize_avg_holes
    fill_in_avgs
  end

  private

  def round_size
    return @number_of_holes + 3 if @number_of_holes == 18

    @number_of_holes + 1 if @number_of_holes == 9
  end

  def initialize_avg_holes
    @average_holes = Array.new(round_size)
    pars = @tee.holes_inorder_with_par_totals
    hdcps = @tee.holes_inorder_with_hdcp_totals
    (1..round_size).each do |num|
      entry = AverageHole.new
      @average_holes[num - 1] = entry
      entry.title = num if num < 10
      entry.par = pars[num - 1].par if pars[num - 1].is_a? Hole
      entry.par = pars[num - 1] unless pars[num - 1].is_a? Hole
      entry.hdcp = hdcps[num - 1].hdcp if hdcps[num - 1].is_a? Hole
      entry.hdcp = hdcps[num - 1] unless hdcps[num - 1].is_a? Hole
      if @number_of_holes == 18
        entry.title = 'Out' if num == 10
        entry.title = num - 1 if num > 10 && num < 20
        entry.title = 'In' if num == 20
        entry.title = 'Total' if num == 21
      elsif num == 10
        entry.title = 'Total'
      end
    end
  end

  def fill_in_avgs
    return if @tee.sorted_rounds.empty?

    out_entry = @average_holes[9]
    in_entry = @average_holes[19]
    total_entry = @average_holes[20]
    @tee.sorted_rounds.each do |round|
      round.sorted_score_holes.each_with_index do |score_hole, index|
        entry = @average_holes[index] if score_hole.hole.number < 10
        entry = @average_holes[index + 1] if score_hole.hole.number > 9
        strokes = score_hole.score.strokes.fdiv(@tee.rounds.size)
        putts = score_hole.score.putts.fdiv(@tee.rounds.size)

        out_entry.strokes += strokes if index < 9
        in_entry.strokes += strokes if index >= 9
        entry.strokes += strokes if out_entry != entry && in_entry != entry
        out_entry.putts += putts if index < 9
        in_entry.putts += putts if index >= 9
        entry.putts += putts if out_entry != entry && in_entry != entry
      end
    end
    total_entry.strokes = out_entry.strokes + in_entry.strokes
    total_entry.putts = out_entry.putts + in_entry.putts
  end
end

# Helper class
#
class AverageHole
  attr_accessor :title, :strokes, :putts, :strokes_under80, :max_strokes, :min_strokes, :par, :hdcp

  # initialize
  #
  def initialize
    super
    @strokes = 0
    @putts = 0
    @strokes_under80 = 0
    @max_strokes = 0
    @min_strokes = 999
  end
end
