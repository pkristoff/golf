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

    expect_rounds_index(page, [@course], false, false)

    click_link(@course.name)

    expect_rounds_tees(page, @course, @course.tees, true, true)

    click_link(@tee.color)

    expect_rounds(page, @course, @tee, [], true, true)
  end

  scenario 'Navigate to a tee with with rounds' do
    @round = FactoryBot.create(:round)
    @tee = @round.tee
    @course = @tee.course

    visit welcome_index_path
    click_button Button::Round::COURSES

    expect_rounds_index(page, [@course], false, false)

    click_link(@course.name)

    expect_rounds_tees(page, @course, @course.tees, true, true)

    click_link(@tee.color)

    expect_rounds(page, @course, @tee, [@round], true, true)
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

    expect_round_form_fields(
      page,
      { date: '2021-04-27',
        course_name: @course.name,
        show_course_tees: true,
        show_round_tees: true },
      Button::Round::CREATE
    )

    fill_in Label::Round::DATE, with: '2021-04-01'

    click_button Button::Round::CREATE

    expect_show_round_form_fields(
      page,
      { date: '2021-04-01',
        course_name: @course.name,
        color: @tee.color,
        disabled: true }
    )
  end
end