# frozen_string_literal: true

require 'common/course_common'
describe 'edit_existing_course' do
  include CourseCommon
  let(:course) { FactoryBot.create(:course) }

  it 'visit edit course' do
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
  end

  it 'visit edit course and make sure errors occur' do
    visit edit_course_path(course.id)

    fill_in Label::Course::NAME, with: ''
    fill_in Label::Course::ZIP, with: ''

    click_button(Button::Course::SUBMIT)

    CourseCommon.expect_edit_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    name: '',
                                    number_of_holes: 18,
                                    street1: '555 Xxx Ave.',
                                    street2: '<nothing>',
                                    city: 'Clarksville',
                                    state: 'IN',
                                    zip_code: '')

    CourseCommon.expect_validation_errors(page, %w[
                                            course_name
                                            course_address_attributes_zip_code
                                          ],
                                          %w[
                                            course_address_attributes_street1
                                            course_address_attributes_city
                                            course_address_attributes_state
                                            course_address_attributes_street2
                                          ])
  end

  it 'visit edit course number of holes' do
    visit edit_course_path(course.id)

    fill_in Label::Course::NAME, with: 'Pete'
    fill_in Label::Course::NUMBER_OF_HOLES, with: 9

    click_button(Button::Course::SUBMIT)

    tees = Course.find_by(id: course.id).tees
    tees.each do |tee|
      expect(tee.holes.size).to eq(9)
    end
    CourseCommon.expect_show_course(page,
                                    course,
                                    tees,
                                    show_tees: true,
                                    course_name: 'Pete',
                                    number_of_holes: 9,
                                    street1: '555 Xxx Ave.',
                                    street2: '<nothing>',
                                    city: 'Clarksville',
                                    state: 'IN',
                                    zip_code: '47529')
  end

  it 'visit edit course and make sure values are updated' do
    visit edit_course_path(course.id)

    fill_in Label::Course::NAME, with: 'George1'
    fill_in Label::Course::STATE, with: 'AK'

    click_button(Button::Course::SUBMIT)

    CourseCommon.expect_show_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: 'George1',
                                    number_of_holes: 18,
                                    street1: '555 Xxx Ave.',
                                    street2: '<nothing>',
                                    city: 'Clarksville',
                                    state: 'AK',
                                    zip_code: '47529')

    CourseCommon.expect_validation_errors(
      page,
      %w[],
      %w[
        course_name
        course_address_attributes_zip_code
        course_address_attributes_street1
        course_address_attributes_city
        course_address_attributes_state
        course_address_attributes_street2
      ]
    )
  end

  it 'visit edit course and go to show courses' do
    visit edit_course_path(course.id)

    click_button(Button::Course::SHOW_COURSES)

    expect(page).to have_selector('h1', text: 'Courses')
  end
end
