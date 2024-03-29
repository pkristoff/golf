# frozen_string_literal: true

require 'common/course_common'
describe 'edit hole buttons' do
  include CourseCommon
  let(:course) { FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true) }
  let(:tee) { course.tee('Black') }
  let(:hole) { tee.hole(5) }

  before do
    visit edit_course_tee_hole_path(course, tee, hole)
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

  it "click I18n.t('button.course.new')" do
    click_button(I18n.t('button.course.new'))

    CourseCommon.expect_new_course(page,
                                   show_tees: false,
                                   course_name: '...',
                                   number_of_holes: '18',
                                   street1: '', street2: '', city: '', state: '', zip_code: '27502')
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

  it "click I18n.t('button.tee.edit')" do
    click_button(I18n.t('button.tee.edit'))

    TeeCommon.expect_edit_tee(page,
                              course.tee('Black'),
                              course.tees,
                              { course_name: course.name,
                                tee_color: 'Black',
                                tee_slope: '139.0',
                                tee_rating: '71.6',
                                show_tees: true })
  end
end
