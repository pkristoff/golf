# frozen_string_literal: true

# RoundInfo
#
class RoundInfo
  include DebugHelper
  attr_accessor :sorted_score_holes, :round, :number_of_holes, :total_score_differential, :sd, :debug_info,
                :par, :adjusted_score, :unadjusted_score, :course_handicap, :slope, :rating

  # calculate score differential
  #
  # === Parameters:
  #
  # * <tt>:initial_handicap_index</tt> initial handicap_index
  #
  def calc_score_differential(initial_handicap_index)
    self.adjusted_score = 0
    self.unadjusted_score = 0
    tee = round.tee
    self.par = tee.total_par
    self.rating = tee.rating
    self.slope = tee.slope
    self.course_handicap = Tee.calc_course_handicap(initial_handicap_index, slope, rating, par)
    # xpp('course_handicap', course_handicap, 'slope', slope, 'rating', rating)
    round.sorted_score_holes.each do |score_hole|
      hole_par = score_hole.hole.par
      adj_score = Tee.calc_adjusted_score(course_handicap, score_hole.score.strokes, hole_par)
      self.unadjusted_score += score_hole.score.strokes
      self.adjusted_score += adj_score
    end
    # xpp('par', tee_par, 'gross_score', gross_score, 'unadjusted_score', unadjusted_score)
    sd1 = Tee.calc_score_differential(self.adjusted_score, rating, slope)
    self.sd = sd1
    puts "setting sd=#{sd}"
    self.total_score_differential = sd1
    total_score_differential
  end

  # print debug info for calculating handicap index
  #
  # === Parameters:
  #
  # * <tt>:diffs_to_use</tt> the score_differentials to avg
  #
  def print_hi_info(diffs_to_use)
    xpp('Course', tee.course.name, 'rd.date', date)
    xpp('  score_diff', format('%.1f', sd),
        'total_score_differential', total_score_differential,
        'use', diffs_to_use.include?(total_score_differential))
    xpp('  course_handicap', course_handicap, 'slope', slope, 'rating', rating)
    xpp('  tee_par', par, 'adjusted_score', adjusted_score, 'gross_score', unadjusted_score)
  end

  # initialize new RoundInfo
  #
  # === Parameters:
  #
  # * <tt>:round</tt> round 18 holes
  # * <tt>:number_of_holes</tt>
  #
  # === Returns:
  #
  # * <tt>:RoundInfo</tt> round] 18 holes
  #
  def initialize(round, number_of_holes)
    @round = round
    @number_of_holes = number_of_holes
    @score_differential = []
  end

  # date of round
  #
  # === Returns:
  #
  # * <tt>:Date</tt> date round played
  #
  delegate :date, to: :round

  # Does round includes round
  #
  # === Parameters:
  #
  # * <tt>:rnd</tt> round
  #
  # === Returns:
  #
  # * <tt>:Boolean</tt>
  #
  def includes?(rnd)
    round == rnd
  end

  # tee of round
  #
  # === Returns:
  #
  # * <tt>:Tee</tt>
  #
  delegate :tee, to: :round

  # ScoreHoles for 18 hole round
  #
  # === Returns:
  #
  # * <tt>:Array</tt> of ScoreHole sorted in number order
  #
  delegate :sorted_score_holes, to: :round
end
