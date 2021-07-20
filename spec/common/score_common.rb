# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'
require 'common/method_common'

module ScoreCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon
    include MethodCommon

    def expect_edit_score(rendered_or_page, round, values, replace_values = [])
      AsideCommon.expect_aside(rendered_or_page, values[:show_tees]) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      expect(rendered_or_page).to have_selector('h1', count: 1, text: 'Edit score:')

      score_holes = round.sorted_score_holes
      expect_scores_link(rendered_or_page, score_holes)
      expect_scores_strokes(rendered_or_page, score_holes, replace_values)
      expect_scores_putts(rendered_or_page, score_holes, replace_values)
      expect_scores_penalties(rendered_or_page, score_holes, replace_values)

      expect_edit_field_set(rendered_or_page, values)

      expect_other_buttons(rendered_or_page)
    end

    private

    def expect_other_buttons(rendered_or_page)
      ButtonToCommon.expect_other_buttons(rendered_or_page,
                                          [
                                            Button::Course::EDIT,
                                            Button::Course::NEW,
                                            Button::Tee::NEW,
                                            Button::Tee::EDIT
                                          ],
                                          [
                                            Button::Round::NEW,
                                            Button::Round::EDIT
                                          ])
    end

    def expect_edit_field_set(rendered_or_page, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Round::EDIT)
      expect_within_edit_fieldset(rendered_or_page, values)
    end

    def expect_within_edit_fieldset(rendered_or_page, values)
      fieldset_subheading = 'div[id=subheading-div][class=fieldset-field-div] '

      MethodCommon.expect_subheading_course_name(rendered_or_page, values[:course_name], fieldset_subheading)
      MethodCommon.expect_subheading_tee_color(rendered_or_page, values[:tee_color], fieldset_subheading)
      MethodCommon.expect_subheading_round_date(rendered_or_page, values[:round_date], fieldset_subheading)
      MethodCommon.expect_subheading_hole_number(rendered_or_page, values[:hole_number], fieldset_subheading)

      fieldset_edit = 'div[id=edit-div][class=fieldset-field-div] '
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Score::STROKES,
                                         'score_strokes',
                                         values[:strokes],
                                         false,
                                         fieldset_edit)
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Score::PUTTS,
                                         'score_putts',
                                         values[:putts],
                                         false,
                                         fieldset_edit)
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Score::PENALTIES,
                                          'score_penalties',
                                          values[:penalties],
                                          false,
                                          fieldset_edit)
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
          value = replace_info[method_name] if hole.number == replace_info[:hole_number]
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
