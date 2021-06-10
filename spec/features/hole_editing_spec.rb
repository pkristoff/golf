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

    expect_edit_hole(page,
                     @tee,
                     { course_name: @course.name,
                       tee_color: @tee.color,
                       show_tees: true,
                       number: '5',
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

    expect_edit_hole(page,
                     @tee,
                     { course_name: @course.name,
                       tee_color: @tee.color,
                       show_tees: true,
                       expect_messages: [[:flash_notice, 'hole updated']],
                       hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                       replace_values: [{ number: 5, yardage: 644, par: 5, hdcp: 10 }],
                       number: '6',
                       yardage: '331',
                       par: '4',
                       hdcp: '7',
                       total_out_yardage: 3113,
                       total_in_yardage: 2734,
                       total_yardage: 5847 })

    # expect_form_holes(page, false,
    #                   expect_messages: [[:flash_notice, 'hole updated']],
    #                   show_tees: true,
    #                   number: '6', yardage: '331', par: '4', hdcp: '7')
    # expect_holes_table(page, @tee.sorted_holes, @tee, {
    #   hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White], number: '5', yardage: '644', par: '5', hdcp: '10'
    # }, [
    #   { number: '5', yardage: '644', par: '5', hdcp: '10' }
    # ])
    # expect_holes(page, @tee.sorted_holes, TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
    #              [{ number: '5', yardage: '644', par: '5', hdcp: '10' }])
    click_link('7')

    expect_edit_hole(page,
                     @tee,
                     { course_name: @course.name,
                       tee_color: @tee.color,
                       show_tees: true,
                       expect_messages: [[:flash_notice, 'hole updated']],
                       hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                       replace_values: [{ number: 5, yardage: 644, par: 5, hdcp: 10 }],
                       number: '7',
                       yardage: '153',
                       par: '3',
                       hdcp: '13',
                       total_out_yardage: 3113,
                       total_in_yardage: 2734,
                       total_yardage: 5847 })

    # expect_form_holes(page, false,
    #                   show_tees: true,
    #                   number: '7', yardage: '153', par: '3', hdcp: '13')
    # expect_holes(page, @tee.sorted_holes, TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
    #              [
    #                { number: '5', yardage: '644', par: '5', hdcp: '10' }
    #              ])

    fill_in Label::Hole::YARDAGE, with: 645
    fill_in Label::Hole::PAR, with: 5
    fill_in Label::Hole::HDCP, with: 9

    click_button('Update Hole')

    expect_edit_hole(page,
                     @tee,
                     { course_name: @course.name,
                       tee_color: @tee.color,
                       show_tees: true,
                       expect_messages: [[:flash_notice, 'hole updated']],
                       hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
                       replace_values: [{ number: 5, yardage: 644, par: 5, hdcp: 10 },
                                        { number: '7', yardage: '645', par: '5', hdcp: '9' }],
                       number: '8', yardage: '375', par: '4', hdcp: '1',
                       total_out_yardage: 3605,
                       total_in_yardage: 2734,
                       total_yardage: 6339 })

    # expect_form_holes(page, false,
    #                   expect_messages: [[:flash_notice, 'hole updated']],
    #                   show_tees: true,
    #                   number: '8', yardage: '375', par: '4', hdcp: '1')
    # expect_holes(page, @tee.sorted_holes, TeeHoleInfo::HOLE_INFO_LOCHMERE[:White],
    #              [
    #                { number: '5', yardage: '644', par: '5', hdcp: '10' },
    #                { number: '7', yardage: '645', par: '5', hdcp: '9' }
    #              ])
  end
end
