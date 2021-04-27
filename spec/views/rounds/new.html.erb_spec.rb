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

    expect_round_form_fields(
      rendered,
      { date: '2021-04-27',
        course_name: tee.course.name,
        tee_color: tee.color },
      Button::Round::CREATE
    )
  end
  it 'initially show list of rounds' do
  end
end
