# frozen_string_literal: true

# A GolfWriter
class GolfWriter
  attr_accessor :write_path, :courses, :workbook

  # Find the Hole with number hole_num
  #
  # === Parameters:
  #
  # * <tt>:write_path</tt> path to write the excel document
  # * <tt>:courses</tt> Array of Course to write
  #
  # === Returns:
  #
  # * <tt>GolfWriter</tt>
  #
  def initialize(write_path, courses)
    @write_path = write_path
    @courses = courses
    fill_in_workbook
  end

  private

  def fill_in_workbook
    create_xlsx
  end

  def create_xlsx
    Axlsx::Package.new do |p|
      @workbook = p.workbook
      @courses.each do |course|
        add_worksheet(@workbook, course)
      end
    end
    # @workbook = Axlsx::Package.new(author: 'Admin').workbook
    # # courses = @rounds.map{|round| round.course}.uniq
    # @courses.each do | course |
    #   add_worksheet(@workbook, course)
    # end
    @workbook
  end

  def add_worksheet(wbk, course)
    wbk.add_worksheet(name: course.name) do |sheet|
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
      row.add_cell('HDCP')
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
      row.add_cell('Par')
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
    num_of_holes = course.num_of_holes
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
