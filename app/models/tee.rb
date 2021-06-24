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
    # puts "sorted=#{holes.sort_by(&:number).map{|h|h.number} }"
    holes.sort_by(&:number)
  end

  # returns rounds sorted by Round.date
  #
  # === Returns:
  #
  # * <tt>Array</tt> rounds sorted by Round.date
  #
  def sorted_rounds
    # puts "sorted=#{holes.sort_by(&:number).map{|h|h.number} }"
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
