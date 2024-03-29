# frozen_string_literal: true

require 'common/course_common'
describe 'edit tee buttons' do
  include CourseCommon
  let(:course) { FactoryBot.create(:course) }
  let(:tee) { course.tee('Blue') }

  before do
    visit edit_course_tee_path(course, tee)
  end

  it "click I18n.t('button.course.edit')" do
    click_button(I18n.t('button.course.edit'))

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

  it "click I18n.t('button.tee.new')" do
    click_button(I18n.t('button.tee.new'))

    TeeCommon.expect_new_tee(page,
                             course,
                             course.tees,
                             { course_name: course.name,
                               tee_color: 'White',
                               tee_slope: '0.0',
                               tee_rating: '0.0',
                               show_tees: true })
  end
end
