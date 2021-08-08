# frozen_string_literal: true

require 'common/course_common'
feature 'edit tee buttons' do
  include CourseCommon
  before(:each) do
    @course = FactoryBot.create(:course)
    @tee = @course.tee('Blue')
    visit edit_course_tee_path(@course, @tee)
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

  scenario 'click Button::Tee::NEW' do
    click_button(Button::Tee::NEW)

    TeeCommon.expect_new_tee(page,
                             @course,
                             @course.tees,
                             { course_name: @course.name,
                               tee_color: 'White',
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })
  end
end
