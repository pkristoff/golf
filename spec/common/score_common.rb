# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'

module ScoreCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon

    def expect_edit_score(rendered_or_page, round, score, values, replace_values = [])
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      expect(rendered_or_page).to have_selector('h1', count: 1, text: 'Edit score:')

      score_holes = round.score_holes
      expect_scores_link(rendered_or_page, score_holes)
      expect_scores_strokes(rendered_or_page, score_holes, replace_values)
      expect_scores_putts(rendered_or_page, score_holes, replace_values)
      expect_scores_penalties(rendered_or_page, score_holes, replace_values)

      expect_edit_field_set(rendered_or_page, round, score, values)

      expect_other_buttons(rendered_or_page)
    end

    private

    def expect_other_buttons(rendered_or_page)
      ButtonToCommon.expect_button_within_course_fieldset(rendered_or_page,
                                                          [
                                                            Button::Tee::EDIT, Button::Tee::NEW, Button::Course::EDIT
                                                          ])
      ButtonToCommon.expect_button_within_round_fieldset(rendered_or_page, [Button::Round::EDIT])
    end

    def expect_edit_field_set(rendered_or_page, round, score, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Round::EDIT)
      expect_within_edit_fieldset(rendered_or_page, round, score, values)
    end

    def expect_within_edit_fieldset(rendered_or_page, round, score, values)
      # rubocop:disable Layout/LineLength
      expect(rendered_or_page).to have_selector('div[id=edit-div][class=fieldset-field-div] h2', count: 1, text: "Course: #{round.tee.course.name}")
      expect(rendered_or_page).to have_selector('div[id=edit-div][class=fieldset-field-div] h2', count: 1, text: "Tee: #{round.tee.color}")
      expect(rendered_or_page).to have_selector('div[id=edit-div][class=fieldset-field-div] h2', count: 1, text: "Date: #{round.date}")
      expect(rendered_or_page).to have_selector('div[id=edit-div][class=fieldset-field-div] h2', count: 1, text: "Hole: #{round.hole(score).number}")

      expect(rendered_or_page).to have_field(Label::Score::STROKES, count: 1)
      expect(rendered_or_page).to have_selector("div[id=edit-div][class=fieldset-field-div] input[id=score_strokes][value='#{values[:strokes]}']")
      expect(rendered_or_page).to have_field(Label::Score::PUTTS, count: 1)
      expect(rendered_or_page).to have_selector("div[id=edit-div][class=fieldset-field-div] input[id=score_putts][value='#{values[:putts]}']")
      expect(rendered_or_page).to have_field(Label::Score::PENALTIES, count: 1)
      expect(rendered_or_page).to have_selector("div[id=edit-div][class=fieldset-field-div] input[id=score_penalties][value='#{values[:penalties]}']")
      # rubocop:enable Layout/LineLength
    end

    def expect_scores_strokes(rendered_or_page, score_holes, replace_values)
      expect_scores_totals(rendered_or_page, score_holes, 'strokes', :strokes, true, replace_values)
    end

    def expect_scores_putts(rendered_or_page, score_holes, replace_values)
      expect_scores_totals(rendered_or_page, score_holes, 'putts', :putts, true, replace_values)
    end

    def expect_scores_penalties(rendered_or_page, score_holes, replace_values)
      expect_scores_totals(rendered_or_page, score_holes, 'penalties', :penalties, false, replace_values)
    end

    def expect_scores_totals(rendered_or_page, score_holes, id_string, method_name, keep_totals, replace_values)
      in_out_tot = 0 if keep_totals
      total = 0 if keep_totals
      score_holes.each do |score_hole|
        score = score_hole.score
        hole = score_hole.hole
        value = score.send(method_name)
        replace_values.each do |replace_info|
          value = replace_info[method_name] if hole.number == replace_info[:number]
        end
        in_out_tot += value if keep_totals
        total += value if keep_totals
        expect(rendered_or_page).to have_selector("td[id=hole-#{id_string}-#{score.id}]", count: 1, text: value)
        case hole.number
        when 9
          # rubocop:disable Layout/LineLength
          expect(rendered_or_page).to have_selector("td[id=total-out-#{id_string}-#{score.id}]", count: 1, text: in_out_tot) if keep_totals
          # rubocop:enable Layout/LineLength
          in_out_tot = 0 if keep_totals
        when 18
          # rubocop:disable Layout/LineLength
          expect(rendered_or_page).to have_selector("td[id=total-in-#{id_string}-#{score.id}]", count: 1, text: in_out_tot) if keep_totals
          expect(rendered_or_page).to have_selector("td[id=total-#{id_string}-#{score.id}]", count: 1, text: total) if keep_totals
          # rubocop:enable Layout/LineLength
        else
          'empty'
        end
      end
    end

    def expect_scores_link(rendered_or_page, score_holes)
      score_holes.each do |score_hole|
        score = score_hole.score
        hole = score_hole.hole
        # rubocop:disable Layout/LineLength
        expect(rendered_or_page).to have_selector("td[id=hole-number-#{hole.id}] a[id=score-link-#{score.id}]", count: 1, text: hole.number)
        # rubocop:enable Layout/LineLength
      end
      expect(rendered_or_page).to have_selector('td', count: 1, text: 'Out')
      expect(rendered_or_page).to have_selector('td', count: 1, text: 'In')
      expect(rendered_or_page).to have_selector('td', count: 1, text: 'Total')
    end
  end
end
