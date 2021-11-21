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

  # Average score per round for a tee
  #
  # sets & returns @average_putts
  #
  # === Returns:
  #
  # * <tt>Array</tt> of AverageScore
  #
  def average_score_totals
    average_strokes = hole_average_strokes
    average_putts = hole_average_putts
    average_strokes_under80 = hole_average_strokes_under80
    avgs = []
    return avgs if @rounds.empty?

    round = @rounds.first unless @rounds.empty?
    average_strokes.each_with_index do |stroke, index|
      hole = nil
      hole = round.score(index + 1).hole if index < 9
      hole = round.score(index).hole if index > 9 && index < 19
      avgs.push(AverageScore.new(hole, stroke, average_putts[index], average_strokes_under80[index]))
    end
    avgs
  end

  private

  def hole_average_strokes_under80
    average_strokes_under80 = Array.new(@number_of_holes + 3, 0)
    out_total_strokes_under80 = 0
    in_total_strokes_under80 = 0
    not_nil_strokes_under80 = 0
    @rounds.each do |round|
      round.sorted_score_holes.each_with_index do |score_hole, index|
        strokes_under80 = score_hole.score.strokes_under80
        out_total_strokes_under80 += strokes_under80 unless strokes_under80.nil? || index >= 9
        in_total_strokes_under80 += strokes_under80 unless strokes_under80.nil? || index < 9
        average_strokes_under80[index] += strokes_under80 unless strokes_under80.nil?
        not_nil_strokes_under80 += 1 unless strokes_under80.nil?
      end
    end
    return average_strokes_under80 if @rounds.empty?

    in_total_strokes_under80 /= not_nil_strokes_under80
    out_total_strokes_under80 /= not_nil_strokes_under80
    total_strokes_under80 = in_total_strokes_under80 + out_total_strokes_under80
    average_strokes_under80 = average_strokes_under80.map { |tot| tot / not_nil_strokes_under80 }

    holes_one_to_nine = average_strokes_under80[0..8]
    out_total = out_total_strokes_under80
    holes_ten_to_eighteen = average_strokes_under80[9..17]
    in_total = in_total_strokes_under80
    @average_putts = (holes_one_to_nine << out_total).concat(holes_ten_to_eighteen) << in_total << total_strokes_under80
  end

  def hole_average_putts
    average_putts = Array.new(@number_of_holes + 3, 0)
    out_total_putts = 0
    in_total_putts = 0
    # puts "putts - @rounds.size=#{@rounds.size}"
    @rounds.each do |round|
      round.sorted_score_holes.each_with_index do |score_hole, index|
        putts = score_hole.score.putts
        out_total_putts += putts if index < 9
        in_total_putts += putts if index >= 9
        average_putts[index] += putts
      end
    end
    return average_putts if @rounds.empty?

    in_total_putts = in_total_putts.fdiv(@rounds.size)
    out_total_putts = out_total_putts.fdiv(@rounds.size)
    total_putts = in_total_putts + out_total_putts
    average_putts = average_putts.map { |tot| tot.fdiv(@rounds.size) }

    @average_putts = (average_putts[0..8] << out_total_putts).concat(average_putts[9..17]) << in_total_putts << total_putts
  end

  def hole_average_strokes
    average_strokes = Array.new(@number_of_holes + 3, 0)
    out_total_strokes = 0
    in_total_strokes = 0
    # puts "strokes - @rounds.size=#{@rounds.size}"
    @rounds.each do |round|
      round.sorted_score_holes.each_with_index do |score_hole, index|
        strokes = score_hole.score.strokes
        out_total_strokes += strokes if index < 9
        in_total_strokes += strokes if index >= 9
        average_strokes[index] += strokes
      end
    end
    return average_strokes if @rounds.empty?

    in_total_strokes = in_total_strokes.fdiv(@rounds.size)
    out_total_strokes = out_total_strokes.fdiv(@rounds.size)
    total_strokes = in_total_strokes + out_total_strokes
    average_strokes = average_strokes.map { |tot| tot.fdiv(@rounds.size) }
    # rubocop:disable Layout/LineLength
    @average_strokes = (average_strokes[0..8] << out_total_strokes).concat(average_strokes[9..17]) << in_total_strokes << total_strokes
    # rubocop:enable Layout/LineLength
  end
end
