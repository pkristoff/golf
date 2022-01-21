# frozen_string_literal: true

# Tee
#
class Tee < ApplicationRecord
  include DebugHelper
  belongs_to(:course)

  has_many(:holes, dependent: :destroy)
  has_many(:rounds, dependent: :destroy)

  validates :color, uniqueness: { case_sensitive: false, scope: :course }
  validates :color, presence: true
  validates :rating, presence: true
  validates :slope, presence: true

  # Add a hole to tee
  #
  # === Parameters:
  #
  # * <tt>:hole_number</tt> golf course hole number
  # * <tt>:yardage</tt> for tee and hole number
  # * <tt>:par</tt> for tee and hole number
  # * <tt>:hdcp</tt> handicap for tee and hole number
  #
  # === Returns:
  #
  # * <tt>Hole</tt>
  #
  def add_hole(hole_number, yardage, par, hdcp)
    hole = Hole.create(number: hole_number, yardage: yardage, par: par, hdcp: hdcp)
    hole.tee = self
    holes.push(hole)
    hole
  end

  # returns the next hole or if at max then returns hole 1.
  #
  # === Parameters:
  #
  # * <tt>:hole</tt> golf course hole
  #
  # === Returns:
  #
  # * <tt>Hole</tt> whose number 1 greater than hole.number
  #
  def next_hole(hole)
    next_number = nil
    number = hole.number
    next_number = number + 1 unless number == number_of_holes
    next_number = 1 if number == number_of_holes
    Hole.find_by(number: next_number, tee_id: id)
  end

  # returns holes sorted by Hole.number
  #
  # === Returns:
  #
  # * <tt>Array</tt> holes sorted by Hole.number
  #
  def sorted_holes
    holes.sort_by(&:number)
  end

  # returns rounds sorted by Round.date
  #
  # === Returns:
  #
  # * <tt>Array</tt> rounds sorted by Round.date
  #
  def sorted_rounds
    rounds.sort_by(&:date)
  end

  # total number holes normally 9 or 18
  #
  # === Returns:
  #
  # * <tt>Integer</tt>
  #
  def number_of_holes
    holes.size
  end

  # The number of holes for the course has been changed
  # so need to adjust the holes.
  #
  def adjust_number_of_holes
    num_of_holes = course.number_of_holes
    return if num_of_holes == number_of_holes

    add_back_nine if num_of_holes == 18 && number_of_holes == 9
    remove_back_nine if num_of_holes == 9 && number_of_holes == 18
  end

  # Add 18 Holes numbered 1-18
  #
  def add_18_holes
    (1...19).each(&method(:add_empty_hole))
    # pprint 'add_18_holes'
  end

  # Add 9 Holes numbered 1-9
  #
  def add_9_holes
    (1...10).each(&method(:add_empty_hole))
    # pprint 'add_9_holes'
  end

  # Find the Hole with number hole_num
  #
  # === Parameters:
  #
  # * <tt>:hole_num</tt> golf course hole number
  #
  # === Returns:
  #
  # * <tt>Hole</tt>
  #
  def hole(hole_num)
    hole = holes.detect { |hle| hle.number == hole_num }
    raise("Hole not found:  #{hole_num}") if hole.nil?

    hole
  end

  # Returns sorted array of holes and integers(representing hdcp totals)
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def holes_inorder_with_hdcp_totals
    holes_inorder_with_totals(:hdcp)
  end

  # Returns sorted array of holes and integers(representing par totals)
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def holes_inorder_with_par_totals
    holes_inorder_with_totals(:par)
  end

  # Returns sorted array of holes and integers (representing yardage totals)
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def holes_inorder_with_yardage_totals
    holes_inorder_with_totals(:yardage)
  end

  # calculate max score allowed for course_hdcp
  #
  # === Parameters:
  #
  # * <tt>:course_hdcp</tt> current course_hdcp
  # * <tt>:hole_par</tt> par for the hole
  #
  # === Returns:
  #
  # * <tt>integer</tt> max strokes allowed for hole
  #
  def self.max_hdcp_score(course_hdcp, hole_par)
    case course_hdcp
    when 0..9
      hole_par + 2
    when 10..19
      7
    when 20..29
      8
    when 30..39
      9
    else
      10
    end
  end

  # Calculate course handicap
  #
  # https://www.usga.org/handicapping/roh/2020-rules-of-handicapping.html
  #
  # === Parameters:
  #
  # * <tt>:handicap_index</tt> the multi-course handicap
  #
  # === Returns:
  #
  # * <tt>Integer</tt>
  #
  def course_handicap(handicap_index)
    # https://www.usga.org/handicapping/roh/2020-rules-of-handicapping.html
    Tee.calc_course_handicap(handicap_index, slope, rating, total_par)
  end

  # calculate par for tee
  #
  # === Returns:
  #
  # * <tt>Integer</tt> par
  #
  def total_par
    Hole.where("tee_id = #{id}").sum(&:par)
  end

  # Calculate adjusted gross score
  #
  # === Parameters:
  #
  # * <tt>:course_handicap</tt> current course handicap
  # * <tt>:strokes</tt> strokes for current hole
  # * <tt>:par</tt> par for current hole
  #
  # === Returns:
  #
  # * <tt>strokes</tt> the minimum of stroes and max hdcp allowed
  #
  def self.calc_adjusted_score(course_handicap, strokes, par)
    max_strokes = Tee.max_hdcp_score(course_handicap, par)
    [max_strokes, strokes].min
  end

  # calculate handicap differential
  #
  # === Parameters:
  #
  # * <tt>:ags</tt> adjusted gross score
  # * <tt>:course_rating</tt> tee rating
  # * <tt>:slope_rating</tt> tee slope rating
  #
  # === Returns:
  #
  # * <tt>Hole</tt>
  #
  def self.calc_score_differential(ags, course_rating, slope_rating)
    # https://www.usga.org/content/usga/home-page/handicapping/world-handicap-system/world-handicap-system-usga-golf-faqs/faqs---what-is-a-score-differential.html
    pcc_adjustment = 0
    score_differential = 113.fdiv(slope_rating) * (ags - course_rating - pcc_adjustment)
    score_differential.round(1)
  end

  # Calculate handicap index
  #
  # === Parameters:
  #
  # * <tt>:score_differentials</tt> Array of scoring differential
  #
  # === Returns:
  #
  # * <tt>Float</tt>truncated to the first decimal place
  #
  def self.final_calc_handicap_index(score_differentials)
    # https://www.usga.org/handicapping/roh/2020-rules-of-handicapping.html
    sorted_score_diff = score_differentials.sort
    case score_differentials.size
    when 1
      adjustment = 4
      diffs_to_use = sorted_score_diff.first(1)
    when 2
      adjustment = 3
      diffs_to_use = sorted_score_diff.first(1)
    when 3
      adjustment = 2
      diffs_to_use = sorted_score_diff.first(1)
    when 4
      adjustment = 1
      diffs_to_use = sorted_score_diff.first(1)
    when 5
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(1)
    when 6
      adjustment = 1
      diffs_to_use = sorted_score_diff.first(2)
    when 7..8
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(2)
    when 9..11
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(3)
    when 12..14
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(4)
    when 15..16
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(5)
    when 17..18
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(6)
    when 19
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(7)
    when 20
      adjustment = 0
      diffs_to_use = sorted_score_diff.first(8)
    else
      raise("Only number of handicap_differentials is 1-20 but '#{score_differentials.size}'")
    end
    lowest_score_diff = diffs_to_use.sum.fdiv(diffs_to_use.size)
    lowest_score_diff_adj = lowest_score_diff - adjustment
    xpp('diffs_to_use', diffs_to_use.map { |x| format('%.1f', x) }, 'adjustment', adjustment)
    xpp('lowest_score_diff', lowest_score_diff, 'lowest_score_diff_adj', lowest_score_diff_adj)
    x = (lowest_score_diff_adj * 0.96).truncate(1)
    xpp('score_index', x)
    x
  end

  # Calculate course handicap
  #
  # === Parameters:
  #
  # * <tt>:handicap_index</tt>
  # * <tt>:slope</tt> tee slope rating
  # * <tt>:rating</tt> tee rating
  # * <tt>:tee_par</tt> par for tee
  #
  # === Returns:
  #
  # * <tt>Float</tt> rouded to first decimal
  #
  def self.calc_course_handicap(handicap_index, slope, rating, tee_par)
    course_hdcp = (handicap_index * (slope / 113)) + (rating - tee_par)
    course_hdcp.round(0)
  end

  private

  def add_empty_hole(num)
    add_hole(num, 0, 0, 0)
  end

  def add_back_nine
    (10...19).each(&method(:add_empty_hole))
  end

  def remove_back_nine
    sorted_holes = holes.sort { |hole1, hole2| hole1.number <=> hole2.number }
    self.holes = sorted_holes[0..8]
  end

  # Returns sorted array of holes and integers(representing totals for yardage, par or hdcp)
  #
  # === Parameters:
  #
  # * <tt>:sym</tt> to get info from hole (:hdcp, :yardage, :par)
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def holes_inorder_with_totals(sym)
    front_nine = 0
    back_nine = 0
    golf_holes = holes.sort { |hole1, hole2| hole1.number <=> hole2.number }
    front_nine = golf_holes[0..8].sum(&sym) unless golf_holes[0].send(sym).nil?
    front_nine = 0 if golf_holes[0].send(sym).nil?

    back_nine = golf_holes[9..17].sum(&sym) unless number_of_holes == 9
    total = front_nine + back_nine
    first_nine_holes = golf_holes[0..8].<<(front_nine)
    return first_nine_holes.concat(golf_holes[9..18].<<(back_nine).<<(total)) if number_of_holes == 18

    golf_holes[0..8].<<(front_nine)
  end

  # debugging only
  def print_hole_with_total(_xxx)
    # xxx.each do |hole|
    #   puts "Hole#{hole.number}" if hole.is_a? Hole
    #   puts "Total#{hole}" unless hole.is_a? Hole
    # end
  end

  # debugging only
  def pprint(_heading = 'No heading')
    #   puts "tee-#{heading}"
    #   puts " color:#{color}"
    #   puts " rating:#{rating}"
    #   puts " slope:#{slope}"
    #   puts " holes"
    #   holes.each do |hole|
    #     puts "   Num:#{hole.number}"
    #     puts "   Yardage:#{hole.yardage}"
    #     puts "   HDCP:#{hole.hdcp}"
    #   end
    #   puts " done-#{heading}"
  end
end
