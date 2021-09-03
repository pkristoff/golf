# frozen_string_literal: true

require 'rails_helper'
require 'common/rounds_common'

describe 'rounds/new.html.erb', type: :view do
  include RoundsCommon
  it 'has fields' do
    tee = FactoryBot.create(:tee)
    assign(:course, tee.course)
    assign(:tee, tee)
    assign(:round, Round.new)

    render

    RoundsCommon.expect_new_round(
      rendered,
      tee,
      { date: '2021-08-21',
        course_name: tee.course.name,
        tee_color: tee.color }
    )
  end
  it 'initially show list of rounds' do
  end
end
