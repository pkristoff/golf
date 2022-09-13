# frozen_string_literal: true

require 'common/course_common'
describe 'new tee buttons' do
  include CourseCommon
  let(:course) { FactoryBot.create(:course) }

  before do
    visit new_course_tee_path(course.id)
  end

  it 'click Button::Course::EDIT' do
    click_button(Button::Course::EDIT)

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
end
