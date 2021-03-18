# frozen_string_literal: true

# A GolfWriter
class GolfWriter
  attr_accessor :write_path, :package

  # Find the Hole with number hole_num
  #
  # === Returns:
  #
  # * <tt>GolfWriter</tt>
  #
  def initialize
    fill_in_workbook
  end

  # save to file
  #
  # === Parameters:
  #
  # * <tt>:write_path</tt> path to write the excel document
  #
  def save_to_file(write_path)
    outstrio = StringIO.new
    outstrio.write(@package.to_stream.read)
    File.open(write_path, 'w') do |file|
      file.write outstrio.string
    end
  end

  private

  def fill_in_workbook
    Axlsx::Package.new(author: 'Paul') do |p|
      p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
      @package = p
      Course.find_each do |course|
        add_worksheet(@package.workbook, course)
      end
    end
    package
  end

  def add_worksheet(wbk, course)
    wbk.add_worksheet(name: course.name) do |sheet|
      add_course(course, sheet) # empty
      add_rounds(Round.rounds(course), sheet)
    end
  end

  def add_course(course, sheet)
    sheet.add_row do |row|
      add_address(course, row)
    end
    sheet.add_row do |row|
      add_holes(course, row)
    end
    sheet.add_row # empty row
    add_tee_rows(course.tees, sheet)
    add_par_rows(course.tees, sheet)
    add_hdcp_rows(course.tees, sheet)
    sheet.add_row
  end

  def add_rounds(rounds, sheet)
    rounds.each do |round|
      sheet.add_row do |row|
        row.add_cell(round.date) # date
      end
      add_score_row(round, round.tee.color, sheet, :strokes)
      add_score_row(round, 'putts', sheet, :putts)
      add_score_row(round, 'penalties', sheet, :penalties)
      sheet.add_row # blank
    end
  end

  def add_score_row(round, cell0, sheet, score_accessor)
    doing_penalties = cell0 == 'penalties'
    sheet.add_row do |row|
      tee = round.tee
      row.add_cell(cell0)
      row.add_cell('') unless tee.slope.zero?
      row.add_cell('') unless tee.rating.zero?
      front_nine = 0 unless doing_penalties
      back_nine = 0 unless doing_penalties
      on_back_nine = false unless doing_penalties
      round.scores.each_with_index do |score, index|
        case index
        when 9
          row.add_cell(front_nine) unless doing_penalties
          on_back_nine = true unless doing_penalties
        end
        row.add_cell(score.send(score_accessor))
        front_nine += score.send score_accessor if !on_back_nine && !doing_penalties
        back_nine += score.send score_accessor if on_back_nine && !doing_penalties
      end
      row.add_cell(front_nine) if !doing_penalties && back_nine.zero?
      row.add_cell(back_nine) if !doing_penalties && !back_nine.zero?
      row.add_cell(front_nine + back_nine) if !doing_penalties && !back_nine.zero?
      puts "scores=#{round.scores.map(&:strokes)}" if score_accessor == :strokes
      puts "row=#{row.cells.map(&:value)}" if score_accessor == :strokes
    end
  end

  def add_row(tee, sheet, row_name, sym)
    sheet.add_row do |row|
      row.add_cell(row_name)
      row.add_cell(nil) unless tee.rating.zero? # rating
      row.add_cell(nil) unless tee.slope.zero? # slope
      tee.holes_inorder_with_totals(sym).each do |hole|
        row.add_cell(hole.send(sym)) if hole.is_a? Hole
        row.add_cell(nil) unless hole.is_a? Hole
      end
    end
  end

  def add_hdcp_rows(tees, sheet)
    tee = tees[0]
    sheet.add_row do |row|
      row.add_cell(Label::Hole::HDCP)
      row.add_cell(nil) unless tee.rating.zero? # rating
      row.add_cell(nil) unless tee.slope.zero? # slope
      tee.holes_inorder_with_hdcp_totals.each do |hole|
        row.add_cell(hole.hdcp) if hole.is_a? Hole
        row.add_cell(nil) unless hole.is_a? Hole
      end
    end
  end

  def add_par_rows(tees, sheet)
    tee = tees[0]
    sheet.add_row do |row|
      row.add_cell(Label::Hole::PAR)
      row.add_cell(nil) unless tee.rating.zero? # rating
      row.add_cell(nil) unless tee.slope.zero? # slope
      tee.holes_inorder_with_par_totals.each do |hole|
        row.add_cell(hole.par) if hole.is_a? Hole
        row.add_cell(hole) unless hole.is_a? Hole
      end
    end
  end

  def add_tee_rows(tees, sheet)
    tees.each do |tee|
      sheet.add_row do |row|
        row.add_cell(tee.color)
        # row.add_cell(0.0) if tee.rating.nil?
        row.add_cell(tee.rating) unless tee.rating.nil? || tee.rating.zero?
        # row.add_cell(0.0) if tee.rating.nil?
        row.add_cell(tee.slope) unless tee.rating.nil? || tee.rating.zero?
        tee.holes_inorder_with_yardage_totals.each do |hole|
          row.add_cell(hole.yardage) if hole.is_a? Hole
          row.add_cell(hole) unless hole.is_a? Hole
        end
      end
    end
  end

  def add_holes(course, row)
    has_rating = course.rate?
    num_of_holes = course.number_of_holes
    row.add_cell('Hole')
    row.add_cell('Rate') if has_rating
    row.add_cell('Slope') if has_rating
    (1..9).each { |hole_num| row.add_cell(hole_num.to_s) }
    row.add_cell('9 Total')
    (10..18).each { |hole_num| row.add_cell(hole_num.to_s) } if num_of_holes == 18
    row.add_cell('9 Total') if num_of_holes == 18
    row.add_cell('18 Total') if num_of_holes == 18
  end

  def add_address(course, row)
    address = course.address
    row.add_cell('Address')
    row.add_cell(address.street_1)
    row.add_cell(address.street_2)
    row.add_cell(address.city)
    row.add_cell(address.state)
    row.add_cell(address.zip_code)
  end
end
