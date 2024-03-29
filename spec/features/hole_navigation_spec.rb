# frozen_string_literal: true

require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'

describe 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon

  it 'Navigate course to tee to holes, then edit hole' do
    course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true)
    visit edit_course_path(course.id)

    CourseCommon.expect_edit_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: 'George',
                                    number_of_holes: 18,
                                    street1: '555 Xxx Ave.',
                                    street2: '<nothing>',
                                    city: 'Clarksville',
                                    state: 'IN',
                                    zip_code: '47529')

    click_link('Black')

    TeeCommon.expect_edit_tee(page,
                              course.tee('Black'),
                              course.tees,
                              { course_name: course.name,
                                tee_color: 'Black',
                                tee_slope: '139.0',
                                tee_rating: '71.6',
                                show_tees: true })

    fill_in 'Slope', with: 140.0
    fill_in('Rating', with: 75.0)
    click_button(I18n.t('button.tee.update'))

    course = Course.find(course.id)

    TeeCommon.expect_edit_tee(page,
                              course.tee('Black'),
                              course.tees,
                              { expect_messages: [[:flash_notice, I18n.t('flash.notice.tee.updated')]],
                                course_name: course.name,
                                tee_color: 'Black',
                                tee_slope: '140.0',
                                tee_rating: '75.0',
                                show_tees: true })

    HoleCommon.expect_holes_list(page, course.tee('Black'),
                                 { hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black],
                                   total_out_yardage: 3366,
                                   total_in_yardage: 3261,
                                   total_yardage: 6627 })

    hole = course.tee('Black').sorted_holes.first
    click_link("hole-number-link-#{hole.id}")

    course = Course.find(course.id)
    tee = course.tee('Black')

    HoleCommon.expect_edit_hole(page,
                                tee,
                                hole,
                                { course_name: course.name,
                                  tee_color: tee.color,
                                  show_tees: true,
                                  expect_messages: [[:flash_notice, 'tee updated']],
                                  hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black],
                                  hole_number: '1', yardage: '411', par: '4', hdcp: '7',
                                  total_out_yardage: 3366,
                                  total_in_yardage: 3261,
                                  total_yardage: 6627 })

    fill_in I18n.t('activerecord.attributes.hole.yardage'), with: 644
    fill_in I18n.t('activerecord.attributes.hole.par'), with: 5
    fill_in I18n.t('activerecord.attributes.hole.hdcp'), with: 10

    click_button('Update Hole')

    HoleCommon.expect_edit_hole(page,
                                tee,
                                course.tee('Black').sorted_holes.second,
                                { course_name: course.name,
                                  tee_color: tee.color,
                                  show_tees: true,
                                  expect_messages: [[:flash_notice, 'hole updated']],
                                  hole_values: TeeHoleInfo::HOLE_INFO_LOCHMERE[:Black],
                                  replace_values: [{ hole_number: 1, yardage: 644, par: 5, hdcp: 10 }],
                                  hole_number: '2', yardage: '360', par: '4', hdcp: '11',
                                  total_out_yardage: 3599,
                                  total_in_yardage: 3261,
                                  total_yardage: 6860 })
  end
end
