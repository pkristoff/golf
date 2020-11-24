# frozen_string_literal: true

require 'rails_helper'
require 'support/tee_hole_info'

describe GolfWriter, type: :model do
  describe 'writing excel spreadsheet' do
    it 'add_tee_rows' do
      Axlsx::Package.new do |p|
        @workbook = p.workbook
      end
    end
    it 'write' do
      golf_reader = GolfReader.new('spec/fixtures/Golf.xlsx')
      courses = golf_reader.courses
      golf_writer = GolfWriter.new('spec/fixtures/Golf_writer.xlsx', courses)
      workbook = golf_writer.workbook
      courses.each do |course|
        nme = course.name.gsub("'", '&apos;')
        sheet = workbook.sheet_by_name(nme)
        expect(sheet).to be_truthy
      end
    end
    it 'write & read compare' do
      golf_reader = GolfReader.new('spec/fixtures/Golf.xlsx')
      golf_writer = GolfWriter.new('spec/fixtures/Golf_writer.xlsx', golf_reader.courses)
      compare_excel(golf_reader.workbook, golf_writer.workbook)
    end
  end
end

def compare_excel(roo_workbook, axlsx_workbook)
  read_sheets = roo_workbook.sheets
  write_sheets = axlsx_workbook.worksheets
  read_sheets.each do |name|
    nme = name.gsub("'", '&apos;')
    expect(axlsx_workbook.sheet_by_name(nme)).to be_truthy
    compare_worksheets(roo_workbook.sheet(name), axlsx_workbook.sheet_by_name(nme))
  end
  expect(write_sheets.size).to eq(read_sheets.size)
end

def compare_worksheets(roo_worksheet, axlsx_worksheet)
  compare_address(roo_worksheet.row(1), axlsx_worksheet.rows[0])
  compare_hole_row(roo_worksheet.row(2), axlsx_worksheet.rows[1])
  compare_empty_row(roo_worksheet.row(3), axlsx_worksheet.rows[2])
  compare_tee_row(roo_worksheet.row(4), axlsx_worksheet.rows[3]) # Black
  compare_tee_row(roo_worksheet.row(5), axlsx_worksheet.rows[4]) # White
  compare_tee_row(roo_worksheet.row(6), axlsx_worksheet.rows[5]) # Blue
  compare_par_row(roo_worksheet.row(7), axlsx_worksheet.rows[6]) # par
  compare_hdcp_row(roo_worksheet.row(8), axlsx_worksheet.rows[7]) # hdcp
end

def compare_empty_row(roo_empty_row, axlsx_empty_row)
  expect(axlsx_empty_row.size).to eq(0)
  (0..roo_empty_row.size - 1).each { |index| expect(roo_empty_row[index]).to be_nil }
end

def compare_hdcp_row(roo_hdcp_row, axlsx_hdcp_row)
  # puts "comparing hdcp row axlsx_tee_row=#{axlsx_tee_row.cells.map { |cell| cell.value }}"
  # puts "comparing hdcp row roo_tee_row=#{roo_tee_row}"
  compare_row_cells(axlsx_hdcp_row, roo_hdcp_row)
  # roo_hdcp_row.each_with_index do |roo_tee_cell, index|
  #   expect(roo_tee_cell).to eq(axlsx_hdcp_row.cells[index].value)
  # end
  # expect(roo_hdcp_row.size).to eq(axlsx_hdcp_row.cells.size)
end

def compare_par_row(roo_par_row, axlsx_par_row)
  # puts "comparing par row roo_par_row=#{axlsx_par_row.cells.map { |cell| cell.value }}"
  # puts "comparing par row roo_tee_row=#{roo_par_row}"
  compare_row_cells(axlsx_par_row, roo_par_row)
end

def compare_tee_row(roo_tee_row, axlsx_tee_row)
  # puts "comparing tee row axlsx_tee_row=#{axlsx_tee_row.cells.map { |cell| cell.value }}"
  # puts "comparing tee row roo_tee_row=#{roo_tee_row}"
  compare_row_cells(axlsx_tee_row, roo_tee_row)
end

def compare_hole_row(roo_hole_row, axlsx_hole_row)
  compare_row_cells(axlsx_hole_row, roo_hole_row)
end

private

def compare_row_cells(axlsx_row, roo_row)
  # puts "comparing par row axlsx_row=#{axlsx_row.cells.map(&:value)}"
  # puts "comparing par row roo_tee_row=#{roo_row}"
  roo_row.each_with_index do |roo_cell, index|
    # rubocop:disable Layout/LineLength
    expect(roo_cell).to eq(axlsx_row.cells[index].value), "tee row not eq roo=#{roo_cell} axlsx=#{axlsx_row.cells[index].value} index=#{index}"
    # rubocop:enable Layout/LineLength
  end
  expect(roo_row.size).to eq(axlsx_row.cells.size)
end

def compare_address(roo_address_row, axlsx_address_row)
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
