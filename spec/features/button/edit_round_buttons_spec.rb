# frozen_string_literal: true

require 'common/course_common'
require 'common/rounds_common'
describe 'new round buttons' do
  include CourseCommon
  include RoundsCommon
  let(:round) { FactoryBot.create(:round) }
  let(:tee) { round.tee }
  let(:course) { tee.course }

  before do
    visit edit_course_tee_round_path(course, tee, round)
  end

  it "click I18n.t('button.course.edit')" do
    click_button(I18n.t('button.course.edit'))

    CourseCommon.expect_edit_course(page,
                                    course,
                                    course.tees,
                                    show_tees: true,
                                    course_name: course.name,
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

  it "click I18n.t('button.round.new_round')" do
    click_button(I18n.t('button.round.new_round'))

    RoundsCommon.expect_new_round(
      page,
      tee,
      { date: '2022-02-03',
        course_name: course.name,
        show_tees: true }
    )
  end

  it "click I18n.t('button.round.edit_round')" do
    click_button(I18n.t('button.round.edit_round'))

    RoundsCommon.expect_edit_round(
      page,
      round,
      { date: round.date,
        course_name: course.name,
        show_tees: true }
    )
  end
end
