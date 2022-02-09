# frozen_string_literal: true

# RoundInfo9
#
class RoundInfo9 < RoundInfo
  attr_accessor :round2, :sd2, :debug_info, :par2, :adjusted_score2, :unadjusted_score2, :course_handicap2,
                :slope2, :rating2

  # calculate score differential
  #
  # === Parameters:
  #
  # * <tt>:initial_handicap_index</tt> initial handicap_index
  #
  def calc_score_differential(initial_handicap_index)
    super
    self.adjusted_score2 = 0
    self.unadjusted_score2 = 0
    tee = round2.tee
    self.par2 = tee.total_par
    self.rating2 = tee.rating
    self.slope2 = tee.slope
    self.course_handicap2 = Tee.calc_course_handicap(initial_handicap_index, slope2, rating2, par2)
    # xpp('course_handicap', course_handicap, 'slope', slope, 'rating', rating)
    round2.sorted_score_holes.each do |score_hole|
      hole_par = score_hole.hole.par
      adj_score = Tee.calc_adjusted_score(course_handicap2, score_hole.score.strokes, hole_par)
      self.unadjusted_score2 += score_hole.score.strokes
      self.adjusted_score2 += adj_score
    end
    sd = Tee.calc_score_differential(adjusted_score2, rating2, slope2)
    self.sd2 = sd
    self.total_score_differential += sd2
    total_score_differential
  end

  # tee of round2
  #
  # === Returns:
  #
  # * <tt>:Tee</tt> tee for round2
  #
  delegate :tee, to: :round2

  # date of round
  #
  # === Returns:
  #
  # * <tt>:Date</tt> date round played
  #
  delegate :date, to: :round2

  # print debug info for calculating handicap index
  #
  # === Parameters:
  #
  # * <tt>:diffs_to_use</tt> the score_differentials to avg
  #
  def print_hi_info(diffs_to_use)
    super
    xpp('Course2', tee.course.name, 'rd2.date', date)
    xpp('  score_diff2', format('%.1f', sd2),
        'total_score_differential', total_score_differential,
        'use', diffs_to_use.include?(total_score_differential))
    xpp('  course_handicap2', course_handicap2, 'slope2', slope2, 'rating2', rating2)
    xpp('  tee_par', par2, 'adjusted_score2', adjusted_score2, 'gross_score2', unadjusted_score2)
  end

  # initialize new RoundInfo
  #
  # === Parameters:
  #
  # * <tt>:rnd1</tt> round 9 holes
  # * <tt>:rnd2</tt> round 9 holes
  # * <tt>:number_of_holes</tt> 9
  #
  # === Returns:
  #
  # * <tt>:RoundInfo9</tt> round] 18 holes
  #
  def initialize(rnd1, rnd2, number_of_holes)
    super(rnd1, number_of_holes)
    @round2 = rnd2
  end

  # tee of round2
  #
  # === Returns:
  #
  # * <tt>:Tee</tt>
  #
  delegate :tee, to: :round2

  # Does round2 == rnd
  #
  # === Parameters:
  #
  # * <tt>:rnd</tt> round for comparison
  #
  # === Returns:
  #
  # * <tt>:Boolean</tt>
  #
  def includes?(rnd)
    super || rnd == round2
  end

  # date of round
  #
  # === Returns:
  #
  # * <tt>:Date</tt> date round played
  #
  delegate :date, to: :round2
end
