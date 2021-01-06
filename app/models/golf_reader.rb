# frozen_string_literal: true

# A GolfReader
class GolfReader
  attr_accessor :path, :workbook

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
    @rounds = []
    fill_in_courses
    fill_in_rounds
    save
  end

  # finds round for given date course and tee color
  #
  # === Parameters:
  #
  # * <tt>:date</tt> played round
  # * <tt>:course</tt> played round on
  # * <tt>:color</tt> tee color
  #
  # === Returns:
  #
  # * <tt>Round</tt> or nil
  #
  def round(date, course, color)
    @rounds.detect { |round| round.course == course && round.tee.color == color && round.date == date }
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
    idx = @courses.find_index { |course| course.name == name }
    raise "Unknown course named: #{name}" if idx.nil?

    @courses[idx]
  end

  private

  def fill_in_courses
    @workbook = fill_in_workbook
    @workbook.sheets.each do |sheet_name|
      @courses.push(process_course(sheet_name))
    end
  end

  def fill_in_rounds
    @workbook.sheets.each do |sheet_name|
      process_rounds_for_course(sheet_name)
    end
  end

  # creates Round objects from Roo objects
  def process_rounds_for_course(sheet_name)
    sheet = @workbook.sheet(sheet_name)
    course = course(sheet_name)
    hdcp_row_num = (1..sheet.last_row).detect { |row| sheet.row(row)[0] == 'HDCP' }
    round_row_num = find_round_row(sheet, hdcp_row_num + 1)
    until round_row_num.nil?
      @rounds.push(process_round(sheet, course, round_row_num)) unless round_row_num.nil?
      round_row_num = find_round_row(sheet, round_row_num + 3)
    end
  end

  def process_round(sheet, course, row_num)
    date_cell = sheet.row(row_num)[0]
    score_row = sheet.row(row_num + 1)
    putts_row = sheet.row(row_num + 2)
    penalties_row = sheet.row(row_num + 3)
    tee_color = score_row[0]
    # puts "course.name=#{course.name} tee_color=#{tee_color}"
    tee = course.tee(tee_color)
    round = Round.create(date: date_cell)
    # puts "  round=#{date_cell}"
    offset = 1 if tee.slope.zero?
    offset = 3 unless tee.slope.zero?
    tee.holes.each_with_index do |hole, index|
      offset += 1 if hole.number == 10
      strokes = score_row[index + offset]
      putts = putts_row[index + offset]
      penalties = penalties_row[index + offset]
      round.add_score(hole, strokes, putts, penalties)
    end
    round
  end

  def find_round_row(sheet, row_num)
    putt_row = (row_num..sheet.last_row).detect { |row| sheet.row(row)[0] == 'putts' }
    # puts "putt_row=#{putt_row}"
    return putt_row - 2 if putt_row.is_a? Integer

    nil if putt_row.nil?
  end

  # creates course objects from Roo objects
  def process_course(sheet_name)
    sheet = @workbook.sheet(sheet_name)
    address_row_num = 1
    tee_row_num = 4
    par_row_num = (tee_row_num..10).detect { |row| sheet.row(row)[0] == 'Par' }
    hdcp_row_num = par_row_num + 1
    header_row_num = 2
    course = Course.new(name: sheet_name)
    process_address(sheet.row(address_row_num), course)
    course.save!
    header_row = sheet.row(header_row_num)
    (tee_row_num..par_row_num - 1).each do |row_num|
      process_tee(course, sheet.row(row_num), header_row, sheet.row(par_row_num), sheet.row(hdcp_row_num))
    end
    course
  end

  def process_address(address_row, course)
    course.address.street_1 = address_row[1].nil? ? '' : address_row[1]
    course.address.street_2 = address_row[2].nil? ? '' : address_row[2]
    course.address.city = address_row[3].nil? ? '' : address_row[3]
    course.address.state = address_row[4].nil? ? '' : address_row[4]
    course.address.zip_code = address_row[5].nil? ? '' : address_row[5]
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
    end_index = header_row.find_index { |cell| cell == '9 Total' } if end_index.nil?

    nine_total = nil
    second_total = nil
    eighteen_total = nil
    # puts "course: #{course.name}, tee:#{tee_color}"
    (start_index..end_index).each do |idx|
      case header_row[idx]
      when '9 Total'
        hole_num = nil
        yardage = tee_row[idx]
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
        hdcp = hdcp_row[idx] unless hdcp_row[idx].nil?
        hdcp = 0 if hdcp_row[idx].nil?
        # puts "[hole_num, yardage, par, hdcp]=#{[hole_num, yardage, par, hdcp]}"
        hole_info.push([hole_num, yardage, par, hdcp])
      end
    end
    tee = course.add_tee(nil, tee_color, rating, slope, hole_info)
    total_holes = tee.number_of_holes

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
    # puts "second_total.nil? || total_holes == 9=#{second_total.nil? || total_holes == 9}"
    unless second_total.nil? || total_holes == 9
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

  # reads in spreadsheed creating Roo objects
  def fill_in_workbook
    @workbook = Roo::Excelx.new(path, file_warning: :ignore)
    @workbook.header_line = 1
    @workbook.default_sheet = workbook.sheets[0]
    @workbook
  end

  def save
    @courses.each(&:save)
    @rounds.each(&:save)
  end
end
