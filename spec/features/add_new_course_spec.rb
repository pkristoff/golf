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
    # puts page.html
    expect_new_fields_with_values(page, '...', '', '', '', '', '27502')

  end

  scenario 'visit new course fill in invalid values &look for errors' do
    visit new_course_path
    expect_new_fields_with_values(page, '...', '', '', '', '', '27502')

    fill_in Label::Course::NAME, with: ''
    fill_in Label::Course::ZIP, with: ''

    click_button('submit-course')

    expect_new_fields_with_values(page, '', '', '', '', '', '')

    expect_validation_errors(%w[
                               course_name
                               course_address_attributes_street_1
                               course_address_attributes_city
                               course_address_attributes_state
                               course_address_attributes_zip_code], %w[
                               course_address_attributes_street_2
                             ])
  end

  scenario 'visit new course fill in valid values it should render show.html.erb' do
    visit new_course_path
    expect_new_fields_with_values(page, '...', '', '', '', '', '27502')

    fill_in Label::Course::NAME, with: 'Lochmere'

    fill_in Label::Course::STREET1, with: '2116 Frissell Ave.'
    fill_in Label::Course::STREET2, with: ''
    fill_in Label::Course::CITY, with: 'Apex'
    fill_in Label::Course::STATE, with: 'NC'
    fill_in Label::Course::ZIP, with: '27502'

    click_button('submit-course')

    expect_edit_fields_with_values(page, 'Lochmere', '2116 Frissell Ave.', '', 'Apex', 'NC', '27502')

    expect_validation_errors(%w[], %w[
                               course_name
                               course_address_attributes_street_1
                               course_address_attributes_street_2
                               course_address_attributes_city
                               course_address_attributes_state
                               course_address_attributes_zip_code
                             ])
  end
end