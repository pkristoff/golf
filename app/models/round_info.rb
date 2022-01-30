# frozen_string_literal: true

# RoundInfo
#
class RoundInfo
  attr_accessor :rounds, :number_of_holes

  # initialize new RoundInfo
  #
  # === Parameters:
  #
  # * <tt>:rounds</tt> [round] 18 holes, [round,round] 9 holes
  # * <tt>:number_of_holes</tt>
  #
  # === Returns:
  #
  # * <tt>:RoundInfo</tt> [round] 18 holes, [round,round] 9 holes
  #
  def initialize(rounds, number_of_holes)
    @rounds = rounds
    @number_of_holes = number_of_holes
  end

  # date of round
  #
  # === Returns:
  #
  # * <tt>:Date</tt> date round played
  #
  def date
    rounds.first.date
  end

  # Does rounds includes round
  #
  # === Parameters:
  #
  # * <tt>:round</tt>
  #
  # === Returns:
  #
  # * <tt>:Boolean</tt>
  #
  def includes?(round)
    rounds.include?(round)
  end

  # tee of round
  #
  # === Returns:
  #
  # * <tt>:Tee</tt>
  #
  def tee
    rounds.first.tee
  end

  # ScoreHoles for 18 hole round
  #
  # === Returns:
  #
  # * <tt>:Array</tt> of ScoreHole sorted in number order
  #
  def sorted_score_holes
    rounds.first.sorted_score_holes
  end
end
