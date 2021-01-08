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
    expect_edit_fields_with_values(page,
                                   'George',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'IN',
                                   '47529')

  end

  scenario 'visit edit course and make sure errors occur' do
    visit edit_course_path(@course.id)

    fill_in Label::Course::NAME, with: ''
    fill_in Label::Course::ZIP, with: ''

    click_button('submit-course')

    expect_edit_fields_with_values(page,
                                   '',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'IN',
                                   '')

    expect_validation_errors(%w[
                                 course_name
                                 course_address_attributes_zip_code], %w[
                                 course_address_attributes_street_1
                                 course_address_attributes_city
                                 course_address_attributes_state
                                 course_address_attributes_street_2
                               ])

  end

  scenario 'visit edit course and make sure values are updated' do
    visit edit_course_path(@course.id)

    fill_in Label::Course::NAME, with: 'George1'
    fill_in Label::Course::STATE, with: 'AK'

    click_button('submit-course')

    expect_show_fields_with_values(page,
                                   'George1',
                                   '555 Xxx Ave.',
                                   '<nothing>',
                                   'Clarksville',
                                   'AK',
                                   '47529')

    expect_validation_errors(%w[],
                             %w[
                                 course_name
                                 course_address_attributes_zip_code
                                 course_address_attributes_street_1
                                 course_address_attributes_city
                                 course_address_attributes_state
                                 course_address_attributes_street_2
                               ])

  end
end
