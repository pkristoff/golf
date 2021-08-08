# frozen_string_literal: true

require 'common/course_common'
feature 'new course buttons' do
  include CourseCommon
  before(:each) do
    visit new_course_path
  end

  after(:each) do
  end

  scenario 'click Button::Course::NEW' do
    # so i can tell the difference
    fill_in Label::Course::NAME, with: 'xxx'

    click_button(Button::Course::NEW)

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18',
                                   street_1: '', street_2: '', city: '', state: '', zip_code: '27502')
  end
end