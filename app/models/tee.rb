# frozen_string_literal: true

# Tee
#
class Tee < ApplicationRecord
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

  # current course handicccap
  # 50 is the given default course handicap
  #
  # === Returns:
  #
  # * <tt>Float</tt> to 1 decimal plasce
  #
  def current_course_handicap
    previous = 0.0
    sorted_rounds.each do |round|
      break if round.handicap.zero?

      previous = round.handicap
    end
    return 50 if previous.zero?

    previous
  end

  # Calculate and saves round handicap
  #
  def set_round_handicap
    sorted_rounds.each do |round|
      course_handicap = calc_course_handicap(round) if round.handicap.zero?
      round.handicap = course_handicap if round.handicap.zero?
      round.save!
    end
  end

  # Calculate adjusted gross score
  #
  # === Parameters:
  #
  # * <tt>:course_hdcp</tt> current course handicap
  # * <tt>:strokes</tt> strokes for current hole
  # * <tt>:par</tt> par for current hole
  #
  # === Returns:
  #
  # * <tt>strokes</tt> the minimum of stroes and max hdcp allowed
  #
  def self.calc_adjusted_score(course_hdcp, strokes, par)
    max_strokes = Tee.max_hdcp_score(course_hdcp, par)
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
    # hd = ((ags - course_rating) * 113) / slope_rating
    # hd.round(1)
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
  def self.calc_scoring_index(score_differentials)
    # https://www.usga.org/content/usga/home-page/handicapping/roh/Content/rules/5%202%20Calculation%20of%20a%20Handicap%20Index.htm
    case score_differentials.size
    when 1
      adjustment = 4
      diffs_to_use = score_differentials.sort.first(1)
    when 2
      adjustment = 3
      diffs_to_use = score_differentials.sort.first(1)
    when 3
      adjustment = 2
      diffs_to_use = score_differentials.sort.first(1)
    when 4
      adjustment = 1
      diffs_to_use = score_differentials.sort.first(1)
    when 5
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(1)
    when 6
      adjustment = 1
      diffs_to_use = score_differentials.sort.first(2)
    when 7..8
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(2)
    when 9..11
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(3)
    when 12..14
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(4)
    when 15..16
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(5)
    when 17..18
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(6)
    when 19
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(7)
    when 20
      adjustment = 0
      diffs_to_use = score_differentials.sort.first(8)
    else
      raise("Only number of handicap_differentials is 1-20 but '#{score_differentials.size}'")
    end
    avg = diffs_to_use.sum.fdiv(diffs_to_use.size) - adjustment
    (avg * 0.96).truncate(1)
  end

  # course handicap
  #
  # === Parameters:
  #
  # * <tt>:round_of_interest</tt> new round
  #
  # === Returns:
  #
  # * <tt>Float</tt> course_hdcp rounded to first decimal
  #
  def calc_course_handicap(round_of_interest)
    found = false
    # https://www.wikihow.com/Calculate-Your-Golf-Handicap
    start_course_handicap = current_course_handicap
    scoring_diffs = []
    tee_par = 0
    sorted_rounds.map do |round|
      break if found

      gross_score = 0
      tee_par = 0
      round.sorted_score_holes.each do |score_hole|
        adj_score = Tee.calc_adjusted_score(start_course_handicap, score_hole.score.strokes, score_hole.hole.par)
        tee_par += score_hole.hole.par
        gross_score += adj_score
      end
      scoring_differential = Tee.calc_score_differential(gross_score, rating, slope)
      found = round_of_interest == round
      scoring_diffs.push(scoring_differential)
    end
    handicap_index = Tee.calc_scoring_index(scoring_diffs)
    Tee.calc_course_handicap(handicap_index, slope, rating, tee_par)
  end

  # Calcuate course handicap
  #
  # === Parameters:
  #
  # * <tt>:handicap_index</tt>
  # * <tt>:slope</tt> tee slope rating
  # * <tt>:rating</tt> tee rating
  # * <tt>:par</tt> par for tee
  #
  # === Returns:
  #
  # * <tt>Float</tt> rouded to first decimal
  #
  def self.calc_course_handicap(handicap_index, slope, rating, par)
    # (Handicap Index) x (Slope Rating) / 113.
    course_hdcp = (handicap_index * (slope / 113)) + (rating - par)
    course_hdcp.round(1)
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

  # debuugging only
  def print_hole_with_total(xxx)
    # xxx.each do |hole|
    #   puts "Hole#{hole.number}" if hole.is_a? Hole
    #   puts "Total#{hole}" unless hole.is_a? Hole
    # end
  end

  # debuugging only
  def pprint(heading = 'No heading')
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
