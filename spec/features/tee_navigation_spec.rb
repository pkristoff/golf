# frozen_string_literal: true

require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'
describe 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon

  it 'Navigate to new.html.erb on Tee' do
    course = FactoryBot.create(:course)
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
    click_button(I18n.t('button.tee.new'))

    course = Course.find_by(id: course.id)
    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { course_name: course.name,
                               tee_color: 'White',
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })
  end

  it 'create a new Tee for course' do
    course = FactoryBot.create(:course, should_fillin_tees: false)
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

    click_button(I18n.t('button.tee.new'))

    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { tee_color: 'White',
                               course_name: course.name,
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })

    fill_in I18n.t('activerecord.attributes.tee.color'), with: 'Black'
    fill_in I18n.t('activerecord.attributes.tee.slope'), with: '139'
    fill_in I18n.t('activerecord.attributes.tee.rating'), with: '71.6'

    click_button(I18n.t('button.tee.create'))
  end

  it 'create a new Tee for course and back to edit course' do
    course = FactoryBot.create(:course, should_fillin_tees: false)
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

    click_button(I18n.t('button.tee.new'))

    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { tee_color: 'White',
                               course_name: course.name,
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })

    fill_in I18n.t('activerecord.attributes.tee.color'), with: 'Black'
    fill_in I18n.t('activerecord.attributes.tee.slope'), with: '139'
    fill_in I18n.t('activerecord.attributes.tee.rating'), with: '71.6'

    click_button(I18n.t('button.tee.create'))
    # expect heading
    expect(page).to have_selector('h1', text: I18n.t('heading.tee.edit'))
    click_button(I18n.t('button.course.edit'))
    expect(page).to have_selector('h1', text: I18n.t('heading.account.edit'))
  end

  it 'create a new Tee for course with a validation error' do
    course = FactoryBot.create(:course, should_fillin_tees: false)
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

    click_button(I18n.t('button.tee.new'))

    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { tee_color: 'White',
                               course_name: course.name,
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })

    fill_in I18n.t('activerecord.attributes.tee.color'), with: 'Black'
    fill_in I18n.t('activerecord.attributes.tee.slope'), with: 0.0
    fill_in I18n.t('activerecord.attributes.tee.rating'), with: 71.6

    click_button(I18n.t('button.tee.create'))
    expect(page).to have_selector('h1', text: I18n.t('heading.tee.edit'))
    click_button(I18n.t('button.course.edit'))
    expect(page).to have_selector('h1', text: I18n.t('heading.account.edit'))
  end

  it 'Navigate to edit.html.erb on Tee with no holes' do
    course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: false)
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
                              { tee_color: 'Black',
                                course_name: course.name,
                                tee_slope: '139.0',
                                tee_rating: '71.6',
                                show_tees: true })

    course.tees.each do |tee|
      HoleCommon.expect_holes_list(page, tee, { hole_values: TeeHoleInfo::HOLE_INFO_EMPTY_18,
                                                total_out_yardage: 0,
                                                total_in_yardage: 0,
                                                total_yardage: 0 })
    end
  end
end
