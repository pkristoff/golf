# frozen_string_literal: true

require 'common/course_common'
feature 'edit_existing_course' do
  include CourseCommon
  before(:each) do
    @course = FactoryBot.create(:course)
  end

  after(:each) do
  end

  scenario 'visit edit course' do
    visit edit_course_path(@course.id)
    CourseCommon.expect_edit_fields_with_values(page,
                                                show_tees: true,
                                                course_name: 'George',
                                                number_of_holes: 18,
                                                street_1: '555 Xxx Ave.',
                                                street_2: '<nothing>',
                                                city: 'Clarksville',
                                                state: 'IN',
                                                zip_code: '47529')
  end

  scenario 'visit edit course and make sure errors occur' do
    visit edit_course_path(@course.id)

    fill_in Label::Course::NAME, with: ''
    fill_in Label::Course::ZIP, with: ''

    click_button('submit-course')

    CourseCommon.expect_edit_fields_with_values(page,
                                                show_tees: true,
                                                name: '',
                                                number_of_holes: 18,
                                                street_1: '555 Xxx Ave.',
                                                street_2: '<nothing>',
                                                city: 'Clarksville',
                                                state: 'IN',
                                                zip_code: '')

    CourseCommon.expect_validation_errors(page, %w[
                                            course_name
                                            course_address_attributes_zip_code
                                          ],
                                          %w[
                                            course_address_attributes_street_1
                                            course_address_attributes_city
                                            course_address_attributes_state
                                            course_address_attributes_street_2
                                          ])
  end

  scenario 'visit edit course number of holes' do
    visit edit_course_path(@course.id)

    fill_in Label::Course::NAME, with: 'Pete'
    fill_in Label::Course::NUMBER_OF_HOLES, with: 9

    click_button('submit-course')

    CourseCommon.expect_show_fields_with_values(page,
                                                show_tees: true,
                                                course_name: 'Pete',
                                                number_of_holes: 9,
                                                street_1: '555 Xxx Ave.',
                                                street_2: '<nothing>',
                                                city: 'Clarksville',
                                                state: 'IN',
                                                zip_code: '47529')
  end

  scenario 'visit edit course and make sure values are updated' do
    visit edit_course_path(@course.id)

    fill_in Label::Course::NAME, with: 'George1'
    fill_in Label::Course::STATE, with: 'AK'

    click_button('submit-course')

    CourseCommon.expect_show_fields_with_values(page,
                                                show_tees: true,
                                                course_name: 'George1',
                                                number_of_holes: 18,
                                                street_1: '555 Xxx Ave.',
                                                street_2: '<nothing>',
                                                city: 'Clarksville',
                                                state: 'AK',
                                                zip_code: '47529')

    CourseCommon.expect_validation_errors(
      page,
      %w[],
      %w[
        course_name
        course_address_attributes_zip_code
        course_address_attributes_street_1
        course_address_attributes_city
        course_address_attributes_state
        course_address_attributes_street_2
      ]
    )
  end

  scenario 'visit edit course and go to show courses' do
    visit edit_course_path(@course.id)

    click_button(Button::Course::SHOW_COURSES)

    expect(page).to have_selector('h1', text: 'Courses')
  end
end
