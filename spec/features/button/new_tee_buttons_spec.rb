# frozen_string_literal: true

require 'common/course_common'
feature 'new tee buttons' do
  include CourseCommon
  before(:each) do
    @course = FactoryBot.create(:course)
    visit new_course_tee_path(@course.id)
  end

  after(:each) do
  end

  scenario 'click Button::Course::EDIT' do
    click_button(Button::Course::EDIT)

    CourseCommon.expect_edit_course(page,
                                    @course,
                                    @course.tees,
                                    show_tees: true,
                                    course_name: 'George',
                                    number_of_holes: 18,
                                    street_1: '555 Xxx Ave.',
                                    street_2: '<nothing>',
                                    city: 'Clarksville',
                                    state: 'IN',
                                    zip_code: '47529')
  end
end
