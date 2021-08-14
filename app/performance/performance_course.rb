class PerformanceCourse
  attr_accessor :in_total, :out_total, :total, :average

  def initialize(rounds, number_of_holes)
    @rounds = rounds
    @number_of_holes = number_of_holes
  end

  def average_with_totals
    hole_average
    (@average[0..8] << @out_total).concat(@average[9..17]) << @in_total << (@in_total + @out_total)
  end

  private

  def hole_average
    @average = Array.new(@number_of_holes, 0)
    @out_total = 0
    @in_total = 0
    @rounds.each do |round|
      round.score_holes.each_with_index do |score_hole, index|
        strokes = score_hole.score.strokes
        @out_total += strokes if index < 9
        @in_total += strokes if index >= 9
        @average[index] += strokes
      end
    end
    return @average if @rounds.empty?

    @in_total = @in_total / @rounds.size
    @out_total = @out_total / @rounds.size
    @total = @in_total + @out_total
    @average = @average.map { |tot| tot / @rounds.size }
  end
end