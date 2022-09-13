# frozen_string_literal: true

require 'common/tee_common'
require 'common/hole_common'
require 'common/course_common'
require 'common/score_common'
describe 'edit_existing_course' do
  include TeeCommon
  include CourseCommon
  include HoleCommon
  include ScoreCommon

  it 'edit a score' do
    round = FactoryBot.create(:round)
    tee = round.tee
    course = tee.course
    score = round.score(1)
    visit welcome_index_path
    click_button Button::Round::COURSES
    click_link(course.name)
    click_link(tee.color)
    click_link(round.date.to_s)
    click_link('1')

    ScoreCommon.expect_edit_score(page, score,
                                  { show_tees: true,
                                    strokes: '5',
                                    putts: 2,
                                    penalties: '',
                                    course_name: course.name,
                                    tee_color: round.tee.color,
                                    round_date: round.date,
                                    hole_number: score.hole.number })

    fill_in Label::Score::STROKES, with: '10'
    fill_in Label::Score::PUTTS, with: '3'
    fill_in Label::Score::PENALTIES, with: 'WW'

    click_button('Update Score')

    next_score = round.next_score(score)
    ScoreCommon.expect_edit_score(
      page, next_score, { show_tees: true, strokes: '5', putts: 2, penalties: '',
                          course_name: course.name,
                          tee_color: round.tee.color,
                          round_date: round.date,
                          hole_number: next_score.hole.number },
      [{ hole_number: 1, strokes: 10, putts: 3, penaties: 'WW' }]
    )
  end
end
