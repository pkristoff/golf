# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe GolfWriter, type: :lib do
  describe 'writing excel spreadsheet' do
    before(:all) do
      puts 'all called'
      @write_path = 'tmp/Golf_writer.xlsx'
      @read_path = 'spec/fixtures/Golf.xlsx'
    end
    before(:each) do
      File.delete(@write_path) if File.exist?(@write_path)
    end
    after(:each) do
      File.delete(@write_path) if File.exist?(@write_path)
    end
    it 'write & read compare' do
      golf_reader = GolfReader.new(@read_path)
      golf_writer = GolfWriter.new
      golf_writer.save_to_file(@write_path)
      expect(File.exist?(@write_path)).to be_truthy
      CompareWorkbook.new.compare_excel(golf_reader.workbook, golf_writer.package.workbook)
    end
  end
end
# compare read (roo) workbook vs write ()axlsx) workbook
#
class CompareWorkbook
  include RSpec::Matchers
  include Capybara::RSpecMatchers
  include Capybara::Node::Finders
  # Compares reader Roo and writer Axlsx for a workbook
  #
  # === Parameters:
  #
  # * <tt>:roo_workbook</tt>
  # * <tt>:axlsx_workbook</tt>
  #
  def compare_excel(roo_workbook, axlsx_workbook)
    read_sheets = roo_workbook.sheets
    write_sheets = axlsx_workbook.worksheets
    read_sheets.each do |name|
      nme = name.gsub("'", '&apos;').gsub('& ', '&amp; ')
      pp "worksheet=#{nme}"
      expect(axlsx_workbook.sheet_by_name(nme)).to be_truthy
      compare_worksheets_courses(roo_workbook.sheet(name), axlsx_workbook.sheet_by_name(nme))
      compare_worksheets_rounds(roo_workbook.sheet(name), axlsx_workbook.sheet_by_name(nme))
    end
    expect(write_sheets.size).to eq(read_sheets.size)
  end

  private

  def pp_on
    false
  end

  def pp(str)
    puts str if pp_on
  end

  def compare_worksheets_rounds(roo_worksheet, axlsx_worksheet)
    roo_date_cell_rows = find_roo_start_round_rows(roo_worksheet)
    axlsx_date_cell_rows = find_axlsx_start_row(axlsx_worksheet)
    roo_date_cell_rows.each_with_index do |date_cell_row, index|
      axlsx_date_cell_row = axlsx_date_cell_rows[index]
      compare_date_row(roo_worksheet.row(date_cell_row), axlsx_worksheet.rows[axlsx_date_cell_row])
      compare_strokes_row(roo_worksheet.row(date_cell_row + 1), axlsx_worksheet.rows[axlsx_date_cell_row + 1], date_cell_row)
      compare_putts_row(roo_worksheet.row(date_cell_row + 2), axlsx_worksheet.rows[axlsx_date_cell_row + 2])
      compare_penalties_row(roo_worksheet.row(date_cell_row + 3), axlsx_worksheet.rows[axlsx_date_cell_row + 3])
    end
  end

  def find_axlsx_start_row(axlsx_worksheet)
    first_nil = false
    second_nil = false
    axlsx_date_cell_rows = []
    axlsx_worksheet.rows.each_with_index do |row, index|
      if second_nil
        axlsx_date_cell_rows << index
        second_nil = false
      end
      second_nil = true if row[0].nil? && first_nil && !second_nil
      first_nil = true if row[0].nil? && !first_nil
    end
    axlsx_date_cell_rows
  end

  def compare_penalties_row(roo_row, axlsx_row)
    expect(roo_row[0]).to eq(axlsx_row[0].value) # penalties
    penalties_cell_num = roo_row[1].nil? ? 3 : 1 # handles when course does not have slope or rating
    roo_penalties = roo_row[penalties_cell_num]
    until roo_penalties.nil?
      expect(roo_penalties).to eq(axlsx_row[penalties_cell_num].value)
      penalties_cell_num += 1
      roo_penalties = roo_row[penalties_cell_num]
    end
  end

  def compare_putts_row(roo_row, axlsx_row)
    expect(roo_row[0]).to eq(axlsx_row[0].value) # putts
    putt_cell_num = roo_row[1].nil? ? 3 : 1 # handles when course does not have slope or rating
    roo_putt = roo_row[putt_cell_num]
    until roo_putt.nil?
      axlsx_putt = axlsx_row[putt_cell_num].value
      expect(roo_putt).to eq(axlsx_putt)
      putt_cell_num += 1
      roo_putt = roo_row[putt_cell_num]
    end
  end

  def compare_strokes_row(roo_row, axlsx_row, date_cell_row)
    expect(roo_row[0]).to eq(axlsx_row[0].value) # tee color
    stroke_cell_num = roo_row[1].nil? ? 3 : 1 # handles when course does not have slope or rating
    roo_stroke = roo_row[stroke_cell_num]
    until roo_stroke.nil?
      unless roo_stroke == axlsx_row[stroke_cell_num].value
        puts "date_cell_row=#{date_cell_row}"
        puts "roo date_cell_rows=#{date_cell_row}"
        puts "stroke_cell_num=#{stroke_cell_num}"
        puts "roo_row=#{roo_row}"
        puts "axlsx_row=#{axlsx_row.cells.map(&:value)}"
      end
      expect(roo_stroke).to eq(axlsx_row[stroke_cell_num].value),
                            "stroke mismatch roo_stroke(#{roo_stroke}) to axlsx (#{axlsx_row[stroke_cell_num].value})"
      stroke_cell_num += 1
      roo_stroke = roo_row[stroke_cell_num]
    end
  end

  def compare_date_row(roo_row, axlsx_row)
    expect(roo_row[0]).to eq(axlsx_row[0].value), "roo_row[0]=#{roo_row[0]} axlsx_row[0].value=#{axlsx_row[0].value}"
  end

  def find_roo_start_round_rows(roo_worksheet)
    hdcp_row_number = find_hdcp_row_number(roo_worksheet)
    date_cell_row = hdcp_row_number + 2
    date_cell_rows = []
    until roo_worksheet.row(date_cell_row)[0].nil?
      date_cell_rows << date_cell_row
      x = date_cell_row + 1
      x += 1 until roo_worksheet.row(x)[0].nil?
      date_cell_row = x + 1
    end
    date_cell_rows
  end

  def find_hdcp_row_number(roo_worksheet)
    i = 1
    i += 1 until roo_worksheet.row(i)[0] == 'HDCP'
    i
  end

  def compare_worksheets_courses(roo_worksheet, axlsx_worksheet)
    compare_address(roo_worksheet.row(1), axlsx_worksheet.rows[0])
    compare_hole_row(roo_worksheet.row(2), axlsx_worksheet.rows[1])
    compare_empty_row(roo_worksheet.row(3), axlsx_worksheet.rows[2])
    i = 4
    while roo_worksheet.row(i)[0] != 'Par'
      compare_tee_row(roo_worksheet.row(i), axlsx_worksheet.rows[i - 1]) # tee
      i += 1
    end
    compare_par_row(roo_worksheet.row(i), axlsx_worksheet.rows[i - 1]) # par
    i += 1
    compare_hdcp_row(roo_worksheet.row(i), axlsx_worksheet.rows[i - 1]) # hdcp
  end

  def compare_empty_row(roo_empty_row, axlsx_empty_row)
    expect(axlsx_empty_row.size).to eq(0)
    (0..roo_empty_row.size - 1).each { |index| expect(roo_empty_row[index]).to be_nil }
  end

  def compare_hdcp_row(roo_hdcp_row, axlsx_hdcp_row)
    pp "hdcp roo cells=#{roo_hdcp_row}"
    pp "hdcp axlsx cells=#{axlsx_hdcp_row.map(&:value)}"
    compare_row_cells(axlsx_hdcp_row, roo_hdcp_row, for_hdcp: true)
  end

  def compare_par_row(roo_par_row, axlsx_par_row)
    pp "par cells roo=#{roo_par_row}"
    pp "par cells axlsx=#{axlsx_par_row.map(&:value)}"
    compare_row_cells(axlsx_par_row, roo_par_row)
  end

  def compare_tee_row(roo_tee_row, axlsx_tee_row)
    pp "tee cells #{roo_tee_row}"
    compare_row_cells(axlsx_tee_row, roo_tee_row)
  end

  # Compares reader Roo and writer Axlsx for a hole row
  #
  # === Parameters:
  #
  # * <tt>:roo_hole_row</tt>
  # * <tt>:axlsx_hole_row</tt>
  #
  def compare_hole_row(roo_hole_row, axlsx_hole_row)
    pp "holes#{roo_hole_row}"
    compare_row_cells(axlsx_hole_row, roo_hole_row)
  end

  def compare_row_cells(axlsx_row, roo_row, for_hdcp: false)
    roo_row.each_with_index do |roo_cell, index|
      rc = 0
      rc = roo_cell unless for_hdcp && roo_cell.nil?
      ac = 0
      ac = axlsx_row.cells[index].value unless for_hdcp && axlsx_row.cells[index].value.nil?
      expect(rc).to eq(ac), "tee row not eq roo=#{rc} axlsx=#{ac} index=#{index}"
    end
    puts "roo_row=#{roo_row}" if roo_row.size != axlsx_row.cells.size
    puts "axlsx_row=#{axlsx_row.cells.map(&:value)}" if roo_row.size != axlsx_row.cells.size
    expect(roo_row.size).to eq(axlsx_row.cells.size),
                            "roo_row.size=#{roo_row.size} does not match axlsx_row.cells.size=#{axlsx_row.cells.size}"
  end

  def compare_address(roo_address_row, axlsx_address_row)
    pp "Address = #{roo_address_row}"
    expect(roo_address_row[0]).to eq(axlsx_address_row.cells[0].value)
    expect(roo_value(roo_address_row[1])).to eq(axlsx_address_row.cells[1].value)
    expect(roo_value(roo_address_row[2])).to eq(axlsx_address_row.cells[2].value)
    expect(roo_value(roo_address_row[3])).to eq(axlsx_address_row.cells[3].value)
    expect(roo_value(roo_address_row[4])).to eq(axlsx_address_row.cells[4].value)
    expect(roo_value(roo_address_row[5])).to eq(axlsx_address_row.cells[5].value)
  end

  def roo_value(val)
    val.nil? ? '' : val
  end
end
