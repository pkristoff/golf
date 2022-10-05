# frozen_string_literal: true

require 'common/course_common'
describe 'edit course buttons' do
  include CourseCommon
  let(:course) { FactoryBot.create(:course) }

  before do
    visit edit_course_path(course.id)
  end

  it "click I18n.t('button.course.new') - course" do
    click_button(I18n.t('button.course.new'))

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18',
                                   street1: '', street22: '', city: '', state: '', zip_code: '27502')
  end

  it "click I18n.t('button.course.new') - tee" do
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
