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
      total_out_strokes = 0
      total_in_strokes = 0
      total_out_putts = 0
      total_in_putts = 0
      round.sorted_score_holes.each_with_index do |score_hole, index|
        entry = @average_holes[index] if score_hole.hole.number < 10
        entry = @average_holes[index + 1] if score_hole.hole.number > 9
        strokes = score_hole.score.strokes
        entry.green_in_regulation = score_hole.score.green_in_regulation
        putts = score_hole.score.putts
        avg_strokes = strokes.fdiv(@tee.rounds.size)
        avg_putts = putts.fdiv(@tee.rounds.size)

        entry.max_strokes = [entry.max_strokes, strokes].max
        entry.min_strokes = [entry.min_strokes, strokes].min

        total_out_strokes += strokes if index < 9
        total_in_strokes += strokes if @number_of_holes == 18 && index >= 9 && index < 19
        # puts "strokes=#{strokes} total_in_strokes=#{total_in_strokes}  index=#{index}"
        total_out_putts += putts if index < 9
        total_in_putts += putts if @number_of_holes == 18 && index >= 9 && index < 19

        out_entry.strokes += avg_strokes if index < 9
        in_entry.strokes += avg_strokes if index >= 9
        entry.strokes += avg_strokes if out_entry != entry && in_entry != entry
        out_entry.putts += avg_putts if index < 9
        in_entry.putts += avg_putts if index >= 9 && @number_of_holes == 18
        entry.putts += avg_putts if out_entry != entry && in_entry != entry
      end
      out_entry.max_strokes = [out_entry.max_strokes, total_out_strokes].max
      out_entry.min_strokes = [out_entry.min_strokes, total_out_strokes].min
      in_entry.max_strokes = [in_entry.max_strokes, total_in_strokes].max if @number_of_holes == 18
      in_entry.min_strokes = [in_entry.min_strokes, total_in_strokes].min if @number_of_holes == 18
      total_entry.max_strokes = [total_entry.max_strokes, total_out_strokes + total_in_strokes].max if @number_of_holes == 18
      total_entry.min_strokes = [total_entry.min_strokes, total_out_strokes + total_in_strokes].min if @number_of_holes == 18
    end
    total_entry.strokes = out_entry.strokes + in_entry.strokes if @number_of_holes == 18
    total_entry.putts = out_entry.putts + in_entry.putts if @number_of_holes == 18
  end
end

# Helper class
#
class AverageHole
  attr_accessor :title, :strokes, :putts, :strokes_under80, :max_strokes, :min_strokes, :par, :hdcp,
                :green_in_regulation

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
