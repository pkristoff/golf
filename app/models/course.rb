# frozen_string_literal: true

# Course
#
class Course < ApplicationRecord
  belongs_to(:address, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:tees, dependent: :destroy)
  accepts_nested_attributes_for(:tees, allow_destroy: true)

  validates :name, uniqueness: { case_sensitive: false }, presence: true

  after_initialize :build_associations, if: :new_record?

  validates_associated :address

  # whether golf course has a rating
  #
  # === Returns:
  #
  # * <tt>Boole</tt>
  #
  def rate?
    tees.first.rating != 0
  end

  # Find the Tee with color
  #
  # === Parameters:
  #
  # * <tt>:color</tt> tee color
  #
  # === Returns:
  #
  # * <tt>Tee</tt>
  #
  def tee(color)
    tees.detect { |tee| tee.color == color }
  end

  # number of holes for course
  #
  # === Returns:
  #
  # * <tt>Integer</tt>
  #
  def num_of_holes
    tees.first.holes.size
  end

  # Create tee if tee is nil
  #
  # === Parameters:
  #
  # * <tt>:tee</tt> nil or Tee if nil create Tee
  # * <tt>:color</tt> color of tee
  # * <tt>:rating</tt> rating of tee
  # * <tt>:slope</tt> slope of tee
  # * <tt>:hole_info</tt> Array of hole_num, yardage, par, hdcp
  #
  # === Returns:
  #
  # * <tt>Tee</tt>
  #
  def add_tee(tee, color, rating, slope, hole_info)
    if tee.nil?
      tee = tees.create(course: self, color: color, rating: rating, slope: slope)
    else
      tee.course = self
      tee.color = color
      tee.rating = rating
      tee.slope = slope
    end
    front_nine = nil
    back_nine = nil
    eighteen = nil
    hole_info.each do |info|
      hole_num = info[0]
      yardage = info[1]
      par = info[2]
      hdcp = info[3].nil? ? 0 : info[3]
      if hole_num.nil?
        eighteen = info if eighteen.nil? && !front_nine.nil? && !back_nine.nil?
        back_nine = info if back_nine.nil? && !front_nine.nil?
        front_nine = info if front_nine.nil?
        next
      end
      tee.add_hole(hole_num, yardage, par, hdcp)
    end
    check_totals(tee, front_nine, back_nine)
    tees.push(tee)
    tee
  end

  def self.basic_permitted_params
    %i[name id]
  end

  private

  # dheck totals for tee if problem raise signal
  #
  # === Parameters:
  #
  # * <tt>:tee</tt> tee
  # * <tt>:front_nine</tt> front nine total
  # * <tt>:back_nine</tt> back nine total
  #
  # === Returns:
  #
  # * <tt>Hole</tt>
  #
  def check_totals(tee, front_nine, back_nine)
    check_hdcp(tee)
    unless front_nine.nil?
      yardage = 0
      par = 0
      (1..9).each do |i|
        tee_hole = tee.hole(i)
        yardage += tee_hole.yardage
        par += tee_hole.par
      end
      raise generate_error_message(name, tee.color, front_nine[1], 'yardage') unless yardage == front_nine[1]
      raise generate_error_message(name, tee.color, front_nine[2], 'par') unless par == front_nine[2]
    end

    return nil if back_nine.nil?

    yardage = 0
    par = 0
    (10..18).each do |i|
      yardage += tee.hole(i).yardage
      par += tee.hole(i).par
    end
    raise generate_error_message(name, tee.color, back_nine[1], 'yardage') unless yardage == back_nine[1]
    raise generate_error_message(name, tee.color, back_nine[2], 'par') unless par == back_nine[2]
  end

  def build_associations
    address || build_address
    true
  end

  def check_hdcp(tee)
    num_of_holes = tee.holes.size
    hdcps = []
    tee.holes.each do |hole|
      hdcp = hole.hdcp
      next if hdcp.nil?

      raise "hdcp (#{hdcp}) larger than number of holes (#{num_of_holes})" if hdcp > num_of_holes

      raise("hdcp problem hdcp: #{hdcp} already used: #{hdcps}") unless hdcps.find_index(hdcp).nil? || hdcp.zero?

      hdcps.push(hdcp)
    end
  end

  def generate_error_message(name, tee_color, total, type)
    "Course: #{name} tee: #{tee_color} #{type} sum problem: expected total=#{total} hole total=#{yardage}"
  end
end
