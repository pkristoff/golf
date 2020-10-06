# frozen_string_literal: true

# A GolfReader
class GolfReader
  attr_accessor :path, :courses

  # initialize with path to xlxs file
  #
  # === Parameters:
  #
  # * <tt>:path</tt> to xlxs file
  #
  # === Returns:
  #
  # * <tt>GolfReader</tt>
  #
  def initialize(path)
    @path = path
    @courses = []
    fill_in_courses
  end

  # Find the Course named <tt> name </tt>
  #
  # === Parameters:
  #
  # * <tt>:name</tt> name of golf course
  #
  # === Returns:
  #
  # * <tt>Course</tt>
  #
  def course(name)
    idx = courses.find_index { |course| course.name == name }
    raise "Unknown course named: #{sheet}" if idx.nil?

    courses[idx]
  end

  private

  def fill_in_courses
    workbook = fill_in_workbook
    workbook.sheets.each do |sheet_name|
      # puts "worksheet=#{sheet_name}"
      courses.push(process_course(workbook, sheet_name))
    end
  end

  def process_course(workbook, sheet_name)
    sheet = workbook.sheet(sheet_name)
    course = Course.new(name: sheet_name)
    header_row = sheet.row(1)
    process_tee(course, sheet.row(3), header_row, sheet.row(6), sheet.row(7))
    process_tee(course, sheet.row(4), header_row, sheet.row(6), sheet.row(7))
    process_tee(course, sheet.row(5), header_row, sheet.row(6), sheet.row(7))
    course
  end

  def process_tee(course, tee_row, header_row, par_row, hdcp_row)
    rating_index = header_row.find_index { |cell| cell == 'Rate' }
    slope_index = header_row.find_index { |cell| cell == 'Slope' }
    rating = rating_index.nil? ? 0 : tee_row[rating_index]
    slope = slope_index.nil? ? 0 : tee_row[slope_index]
    tee_color = tee_row[0]
    # puts "process_tee(course, tee_row, header_row): #{tee_color}:#{rating}"
    hole_info = []
    start_index = header_row.find_index do |cell|
      cell == 1
    end
    end_index = header_row.find_index { |cell| cell == '18 Total' }

    # puts "start_index=#{start_index}"
    # puts "end_index=#{end_index}"

    nine_total = nil
    second_total = nil
    eighteen_total = nil
    # puts "course: #{course.name}, tee:#{tee_color}"
    (start_index..end_index).each do |idx|
      case header_row[idx]
      when '9 Total'
        hole_num = nil
        yardage = tee_row[idx]
        # puts "9 - total yardage: #{yardage}"
        par = par_row[idx]
        nine_total = [hole_num, yardage, par] if nine_total.nil?
        second_total = [hole_num, yardage, par] unless nine_total.nil?
      when '18 Total'
        hole_num = nil
        yardage = tee_row[idx]
        # puts "18 total yardage: #{yardage}"
        par = par_row[idx]
        eighteen_total = [hole_num, yardage, par]
      else
        hole_num = header_row[idx].to_i
        yardage = tee_row[idx]
        # puts "#{header_row[idx]} yardage: #{yardage}"
        par = par_row[idx]
        hdcp = hdcp_row[idx]
        hole_info.push([hole_num, yardage, par, hdcp])
      end
    end
    tee = course.add_tee(tee_color, rating, slope, hole_info)

    unless nine_total.nil?
      yardage = 0
      par = 0
      (1..9).each do |i|
        yardage += tee.hole(i).yardage
        par += tee.hole(i).par
      end
      err_msg = err_msg_header(course.name, tee_color)
      expected_yards = nine_total[1]
      yardage_err_msg = "#{err_msg} yardage sum problem: expected total=#{expected_yards} hole total=#{yardage}"
      raise yardage_err_msg unless yardage == expected_yards

      expected_par = nine_total[2]
      par_err_msg = "#{err_msg} yardage sum problem: expected total=#{expected_par} hole total=#{par}"
      raise par_err_msg unless par == expected_par
    end

    unless second_total.nil?
      yardage = 0
      par = 0
      (10..18).each do |i|
        yardage += tee.hole(i).yardage
        par += tee.hole(i).par
      end
    end
    err_msg = err_msg_header(course.name, tee_color)
    expected_yards = second_total[1]
    yardage_err_msg = "#{err_msg} yardage sum problem: expected total=#{expected_yards} hole total=#{yardage}"
    raise yardage_err_msg unless yardage == expected_yards

    err_msg = err_msg_header(course.name, tee_color)
    expected_par = second_total[2]
    raise "#{err_msg} par sum problem: expected total=#{expected_par} hole total=#{par}" unless par == expected_par
  end

  def err_msg_header(course_name, tee_color)
    "Course: #{course_name} tee: #{tee_color}"
  end

  # def process_tees(course, sheet)
  #   # header_row = sheet.row(1)
  #   # puts "sheet.row(6)=#{sheet.row(6)}"
  #   laet_tee_row = sheet.row(6)
  #   2..sheet.row(laet_tee_row)
  # end

  def fill_in_workbook
    workbook = Roo::Excelx.new(path, file_warning: :ignore)
    workbook.header_line = 1
    workbook.default_sheet = workbook.sheets[0]
    workbook
  end
end
