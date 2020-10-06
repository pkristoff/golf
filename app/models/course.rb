# frozen_string_literal: true

# Course
#
class Course < ApplicationRecord
  belongs_to(:address, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:tees, dependent: :destroy)
  accepts_nested_attributes_for(:tees, allow_destroy: true)

  after_initialize :build_associations, if: :new_record?

  # Add Tee with color
  #
  # === Parameters:
  #
  # * <tt>:color</tt> color of tee
  # * <tt>:rating</tt> rating of tee
  # * <tt>:slope</tt> slope of tee
  # * <tt>:hole_info</tt> Array of hole_num, yardage, par, hdcp
  #
  # === Returns:
  #
  # * <tt>Tee</tt>
  #
  def add_tee(color, rating, slope, hole_info)
    tee = Tee.new(color: color, rating: rating, slope: slope)
    tee.course = self
    tee.add_18_holes
    front_nine = nil
    back_nine = nil
    eighteen = nil
    hole_info.each do |info|
      hole_num = info[0]
      yardage = info[1]
      par = info[2]
      hdcp = info[3]
      if hole_num.nil?
        eighteen = info if eighteen.nil? && !front_nine.nil? && !back_nine.nil?
        back_nine = info if back_nine.nil? && !front_nine.nil?
        front_nine = info if front_nine.nil?
        next
      end
      hole = tee.hole(hole_num)
      hole.yardage = yardage
      hole.par = par
      hole.hdcp = hdcp
    end
    check_totals(tee, front_nine, back_nine)
    tees.push(tee)
    tee
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
    idx = tees.index { |x| x.color == color }
    return nil if idx.nil?

    tees[idx]
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

  def generate_error_message(name, tee_color, total, type)
    "Course: #{name} tee: #{tee_color} #{type} sum problem: expected total=#{total} hole total=#{yardage}"
  end
end
