# frozen_string_literal: true

require 'rails_helper'
require 'common/peformances_common'

RSpec.describe 'performances/index.html.erb', type: :view do
  include PerformancesCommon
  it 'show performance no rounds' do
    round = FactoryBot.create(:round)
    tee = round.tee
    expect(tee.rounds.size).to eq(1)
    round.destroy
    course = tee.course

    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, tee)
    assign(:performance, PerformanceCourse.new(tee, course.number_of_holes))

    render

    PerformancesCommon.expect_index(rendered,
                                    {
                                      course_name: course.name,
                                      tee_color: tee.color,
                                      tee_id: tee.id,
                                      avg_strokes: [],
                                      avg_putts: []
                                    })
  end
  it 'show performance 1 round' do
    round = FactoryBot.create(:round)
    tee = round.tee
    course = tee.course

    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, tee)
    assign(:performance, PerformanceCourse.new(tee, course.number_of_holes))

    render

    PerformancesCommon.expect_index(rendered,
                                    {
                                      course_name: course.name,
                                      tee_color: tee.color,
                                      tee_id: tee.id,
                                      avg_strokes: [5, 5, 4, 6, 4, 5, 4, 6, 5, 44, 5, 3, 6, 5, 6, 5, 5, 5, 5, 45, 89],
                                      avg_putts: [2, 2, 2, 3, 3, 2, 2, 3, 1, 20, 1, 1, 1, 2, 3, 1, 2, 2, 2, 15, 35]
                                    })
  end
  it 'show performance 2 rounds' do
    round = FactoryBot.create(:round)
    tee = round.tee
    course = tee.course
    round2 = FactoryBot.create(:round, tee: tee, round_score_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO2])
    expect(tee).to eq(round2.tee)
    expect(tee.sorted_rounds.size).to eq(2)

    assign(:course, course)
    assign(:form_disabled, false)
    assign(:tee, tee)
    assign(:performance, PerformanceCourse.new(tee, course.number_of_holes))

    render

    PerformancesCommon.expect_index(rendered,
                                    {
                                      course_name: course.name,
                                      tee_color: tee.color,
                                      tee_id: tee.id,
                                      # rubocop:disable Layout/LineLength
                                      avg_strokes: [6.5, 5.0, 4.0, 6.0, 4.0, 5.0, 4.0, 6.0, 6.0, 46.5, 4.0, 3.0, 6.0, 5.0, 6.0, 5.0, 5.0, 5.0, 4.5, 43.5, 90.0],
                                      avg_putts: [1.5, 2.0, 2.0, 3.0, 3.0, 2.0, 2.0, 3.0, 3.0, 21.5, 2.0, 1.0, 1.0, 2.0, 3.0, 1.0, 2.0, 2.0, 1.5, 15.5, 37.0]
                                      # rubocop:enable Layout/LineLength
                                    })
  end
end
