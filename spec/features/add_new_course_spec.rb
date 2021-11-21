# frozen_string_literal: true

require 'common/course_common'
feature 'add a new course' do
  include CourseCommon
  # include ViewsHelpers
  before(:each) do
  end

  after(:each) do
  end

  scenario 'visit new course' do
    visit new_course_path

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18',
                                   street1: '', street2: '', city: '', state: '', zip_code: '27502')
  end

  scenario 'visit new course fill in invalid values &look for errors' do
    visit new_course_path
    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18', street1: '', street2: '',
                                   city: '', state: '', zip_code: '27502')

    fill_in Label::Course::NAME, with: ''
    fill_in Label::Course::NUMBER_OF_HOLES, with: 0
    fill_in Label::Course::ZIP, with: ''

    click_button(Button::Course::SUBMIT)

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '',
                                   number_of_holes: '0', street1: '', street2: '', city: '', state: '', zip: '')

    CourseCommon.expect_validation_errors(page, %w[
                                            course_name
                                            course_address_attributes_street1
                                            course_address_attributes_city
                                            course_address_attributes_state
                                            course_address_attributes_zip_code
                                          ],
                                          %w[
                                            course_address_attributes_street2
                                          ])
  end

  scenario 'visit new course fill in valid values it should render index.html.erb' do
    visit new_course_path
    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...', number_of_holes: '18',
                                   street1: '', street2: '', city: '', state: '', zip_code: '27502')

    fill_in Label::Course::NAME, with: 'Lochmere'

    fill_in Label::Course::STREET1, with: '2116 Frissell Ave.'
    fill_in Label::Course::STREET2, with: ''
    fill_in Label::Course::CITY, with: 'Apex'
    fill_in Label::Course::STATE, with: 'NC'
    fill_in Label::Course::ZIP, with: '27502'

    click_button(Button::Course::SUBMIT)

    expect(Course.all.size).to eq(1)

    course = Course.all.first
    # no tees defined so go to edit
    CourseCommon.expect_edit_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: 'Lochmere',
                                    number_of_holes: '18',
                                    street1: '2116 Frissell Ave.',
                                    street2: '',
                                    city: 'Apex',
                                    state: 'NC',
                                    zip_code: '27502')

    CourseCommon.expect_validation_errors(
      page,
      %w[],
      %w[
        course_name
        course_address_attributes_street1
        course_address_attributes_street2
        course_address_attributes_city
        course_address_attributes_state
        course_address_attributes_zip_code
      ]
    )

    click_button(Button::Tee::NEW)

    expect(Course.all.size).to eq(1)

    course = Course.all.first

    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { course_name: course.name,
                               tee_color: 'White',
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })

    fill_in 'Slope', with: 140.0
    fill_in('Rating', with: 75.0)

    click_button(Button::Tee::CREATE)

    click_button(Button::Course::EDIT)

    click_button(Button::Course::UPDATE)

    CourseCommon.expect_show_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: 'Lochmere',
                                    number_of_holes: '18',
                                    street1: '2116 Frissell Ave.',
                                    street2: '',
                                    city: 'Apex',
                                    state: 'NC',
                                    zip_code: '27502')
  end
end
