# frozen_string_literal: true

require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'
require 'common/score_common'
feature 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon
  include ScoreCommon
  before(:each) do
  end

  after(:each) do
  end

  scenario 'edit a score' do
    @round = FactoryBot.create(:round)
    @tee = @round.tee
    @course = @tee.course
    @score = @round.score(1)
    visit welcome_index_path
    click_button Button::Round::COURSES
    click_link(@course.name)
    click_link(@tee.color)
    click_link(@round.date.to_s)
    click_link('1')

    expect_edit_score(page, @round, @score, { show_course_tees: true, show_round_tees: true,
                                              strokes: '5', putts: 2, penalties: '' })

    fill_in Label::Score::STROKES, with: '10'
    fill_in Label::Score::PUTTS, with: '3'
    fill_in Label::Score::PENALTIES, with: 'WW'

    click_button('Update Score')

    expect_edit_score(page, @round, @round.next_score(@score), { show_course_tees: true, show_round_tees: true,
                                                                 strokes: '5', putts: 2, penalties: '' },
                      [{ number: 1, strokes: 10, putts: 3, penaties: 'WW' }])
  end
end
