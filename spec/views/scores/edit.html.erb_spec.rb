# frozen_string_literal: true

require 'rails_helper'
require 'common/score_common'

describe 'scores/edit.html.erb', type: :view do
  include ScoreCommon
  it 'edits first score' do
    round = FactoryBot.create(:round)
    tee = round.tee
    course = tee.course
    score = round.score(1)

    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, tee)
    assign(:round, round)
    assign(:score, score)

    render

    expect_edit_score(rendered, round, score, { strokes: 5,
                                                putts: 2,
                                                penalties: '' })
  end

  it 'edits 3rd hole' do
    round = FactoryBot.create(:round)
    tee = round.tee
    course = tee.course
    score = round.score(3)
    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, tee)
    assign(:round, round)
    assign(:score, score)

    render

    expect_edit_score(rendered, round, score, { strokes: 4,
                                                putts: 2,
                                                penalties: '' })
  end
end
