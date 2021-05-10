# frozen_string_literal: true

# Course
#
class Course < ApplicationRecord
  belongs_to(:address, validate: false, dependent: :destroy)
  accepts_nested_attributes_for(:address, allow_destroy: true)

  has_many(:tees, dependent: :destroy)
  accepts_nested_attributes_for(:tees, allow_destroy: true)

  validates :name, uniqueness: { case_sensitive: false }, presence: true

  validates :number_of_holes, presence: true, inclusion: [9, 18]

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
    if hole_info.empty?
      tee.add_9_holes if number_of_holes == 9
      tee.add_18_holes if number_of_holes == 18
    else
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
    end
    check_totals(tee, front_nine, back_nine)
    tees.push(tee)
    tee
  end

  # Returns list tees based on color
  #
  # === Returns:
  #
  # * <tt>Array</tt> sorted based on tee color
  #
  def sorted_tees
    tees.sort_by(&:color)
  end

  def self.basic_permitted_params
    %i[name id number_of_holes]
  end

  private

  # check totals for tee if problem raise signal
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
    course = tee.course
    name = course.name
    if course.number_of_holes != tee.holes.size
      # rubocop:disable Layout/LineLength
      raise "Course: #{name} tee: #{tee.color} number of holes mismatch declared: #{course.number_of_holes} actual: #{tee.holes.size}"
      # rubocop:enable Layout/LineLength
    end

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
    hdcps = []
    tee.sorted_holes.each do |hole|
      hdcp = hole.hdcp
      next if hdcp.nil?

      raise "hdcp (#{hdcp}) larger than number of holes (#{number_of_holes})" if hdcp > number_of_holes

      raise("hdcp problem hdcp: #{hdcp} already used: #{hdcps}") unless hdcps.find_index(hdcp).nil? || hdcp.zero?

      hdcps.push(hdcp)
    end
  end

  def generate_error_message(name, tee_color, total, type)
    "Course: #{name} tee: #{tee_color} #{type} sum problem: expected total=#{total} hole total=#{yardage}"
  end
end
