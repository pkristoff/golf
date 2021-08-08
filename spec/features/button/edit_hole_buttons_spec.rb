# frozen_string_literal: true

require 'common/course_common'
feature 'edit hole buttons' do
  include CourseCommon
  before(:each) do
    @course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true)
    @tee = @course.tee('Black')
    @hole = @tee.hole(5)
    visit edit_course_tee_hole_path(@course, @tee, @hole)
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

  scenario 'click Button::Course::NEW' do
    click_button(Button::Course::NEW)

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18',
                                   street_1: '', street_2: '', city: '', state: '', zip_code: '27502')
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

  scenario 'click Button::Tee::EDIT' do
    click_button(Button::Tee::EDIT)

    TeeCommon.expect_edit_tee(page,
                              @course.tee('Black'),
                              @course.tees,
                              { course_name: @course.name,
                                tee_color: 'Black',
                                tee_slope: '139.0',
                                tee_rating: '71.6',
                                show_tees: true })
  end
end
