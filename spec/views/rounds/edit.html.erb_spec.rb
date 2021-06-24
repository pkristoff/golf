# frozen_string_literal: true

require 'rails_helper'
require 'common/rounds_common'

describe 'rounds/edit.html.erb', type: :view do
  include RoundsCommon
  it 'has fields' do
    # tee = FactoryBot.create(:tee)
    round = FactoryBot.create(:round)
    tee = round.tee
    assign(:course, tee.course)
    assign(:tee, tee)
    assign(:round, round)

    render

    RoundsCommon.expect_round_form_fields(
      rendered,
      { date: Time.zone.today.to_s,
        course_name: 'prk' },
      Button::Round::UPDATE
    )
  end
  it 'initially show list of rounds' do
  end
end
