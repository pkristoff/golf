# frozen_string_literal: true

require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'
require 'common/rounds_common'

feature 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon
  include RoundsCommon

  before(:each) do
  end

  after(:each) do
  end
  scenario 'Navigate to a tee with no rounds' do
    @course = FactoryBot.create(:course, should_fillin_tees: true, should_fillin_holes: true)
    @tee = @course.tee('Black')
    visit welcome_index_path
    click_button Button::Round::COURSES

    RoundsCommon.expect_index_rounds_course(page, [@course])

    click_link(@course.name)

    RoundsCommon.expect_rounds_tees(page, @course, @course.tees)

    click_link(@tee.color)

    RoundsCommon.expect_index_rounds(page, @course, @tee, [], true)
  end

  scenario 'Navigate to a tee with with rounds' do
    @round = FactoryBot.create(:round)
    @tee = @round.tee
    @course = @tee.course

    visit welcome_index_path
    click_button Button::Round::COURSES

    RoundsCommon.expect_index_rounds_course(page, [@course])

    click_link(@course.name)

    RoundsCommon.expect_rounds_tees(page, @course, @course.tees)

    click_link(@tee.color)

    RoundsCommon.expect_index_rounds(page, @course, @tee, [@round], true)
  end
  it 'Create a new round' do
    @round = FactoryBot.create(:round)
    @tee = @round.tee
    @course = @tee.course

    visit welcome_index_path
    click_button Button::Round::COURSES
    click_link(@course.name)
    click_link(@tee.color)
    click_button Button::Round::NEW

    RoundsCommon.expect_new_round(
      page,
      @tee,
      { date: '2022-01-19',
        course_name: @course.name,
        show_tees: true }
    )

    fill_in Label::Round::DATE, with: '2021-09-03'

    click_button Button::Round::CREATE

    round = Round.find_by(date: '2021-09-03')

    RoundsCommon.expect_show_round(
      page,
      round,
      { date: '2021-09-03',
        course_name: @course.name,
        color: @tee.color,
        show_tees: true }
    )
  end
end
