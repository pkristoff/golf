# frozen_string_literal: true

require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'
feature 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon
  before(:each) do
  end

  after(:each) do
  end

  scenario 'edit a holes' do
    @course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true)
    @tee = @course.tee('White')
    @hole = @tee.hole(5)
    visit edit_course_tee_hole_path(@course, @tee, @hole)

    HoleCommon.expect_edit_hole(page,
                                @tee,
                                @hole,
                                { course_name: @course.name,
                                  tee_color: @tee.color,
                                  show_tees: true,
                                  hole_number: '5',
                                  yardage: '332',
                                  par: '4',
                                  hdcp: '17',
                                  hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                                  replace_values: [],
                                  total_out_yardage: 2801,
                                  total_in_yardage: 2734,
                                  total_yardage: 5535 })

    fill_in Label::Hole::YARDAGE, with: 644
    fill_in Label::Hole::PAR, with: 5
    fill_in Label::Hole::HDCP, with: 10

    click_button('Update Hole')

    HoleCommon.expect_edit_hole(page,
                                @tee,
                                @tee.hole(6),
                                { course_name: @course.name,
                                  tee_color: @tee.color,
                                  show_tees: true,
                                  expect_messages: [[:flash_notice, 'hole updated']],
                                  hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                                  replace_values: [{ hole_number: 5, yardage: 644, par: 5, hdcp: 10 }],
                                  hole_number: '6',
                                  yardage: '331',
                                  par: '4',
                                  hdcp: '7',
                                  total_out_yardage: 3113,
                                  total_in_yardage: 2734,
                                  total_yardage: 5847 })

    click_link('7')

    HoleCommon.expect_edit_hole(page,
                                @tee,
                                @tee.hole(7),
                                { course_name: @course.name,
                                  tee_color: @tee.color,
                                  show_tees: true,
                                  expect_messages: [[:flash_notice, 'hole updated']],
                                  hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                                  replace_values: [{ hole_number: 5, yardage: 644, par: 5, hdcp: 10 }],
                                  hole_number: '7',
                                  yardage: '153',
                                  par: '3',
                                  hdcp: '13',
                                  total_out_yardage: 3113,
                                  total_in_yardage: 2734,
                                  total_yardage: 5847 })

    click_button('Update Hole')

    HoleCommon.expect_edit_hole(page,
                                @tee,
                                @tee.hole(8),
                                { course_name: @course.name,
                                  tee_color: @tee.color,
                                  show_tees: true,
                                  expect_messages: [[:flash_notice, 'hole updated']],
                                  hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                                  replace_values: [{ hole_number: 5, yardage: 644, par: 5, hdcp: 10 }],
                                  hole_number: '8', yardage: '375', par: '4', hdcp: '1',
                                  total_out_yardage: 3113,
                                  total_in_yardage: 2734,
                                  total_yardage: 5847 })
  end
end
