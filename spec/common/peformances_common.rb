# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'
require 'common/method_common'

# ScoreCommon
#
module PerformancesCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    include AsideCommon
    include DatabaseCommon

    # expect oerformance index
    #
    # === Parameters:
    #
    # * <tt>:rendered_or_page</tt> html
    # * <tt>:values</tt> Hash of symbol value pairs
    #
    def expect_index(rendered_or_page, values = {})
      AsideCommon.expect_aside(rendered_or_page, true) unless rendered_or_page.is_a? String
      DatabaseCommon.expect_database(rendered_or_page) unless rendered_or_page.is_a? String

      expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

      MethodCommon.expect_heading(rendered_or_page, Heading::Performances::PERFORMANCES)

      expect_show_fieldset(
        rendered_or_page,
        values
      )

      # expect_edit_other_buttons(rendered_or_page)
    end

    private

    def expect_show_fieldset(rendered_or_page, values)
      expect(rendered_or_page).to have_selector('fieldset', count: 1, text: Fieldset::Show::SHOW)
      expect_show_subheadings(rendered_or_page, values, Fieldset::Edit::SUBHEADING)
      fieldset_txt = 'div[id=fieldset-div][class=fieldset-field-div] '
      if values[:avg_strokes].empty?
        expect(rendered_or_page).to have_selector("#{fieldset_txt}p", count: 1, text: 'No rounds for tee')
      else
        expect_field_values_score(rendered_or_page, values, fieldset_txt)
      end
    end

    def expect_field_values_score(rendered_or_page, values, fieldset_txt)
      table_txt = "#{fieldset_txt}table[id=holes-#{values[:tee_id]}]"
      expect(rendered_or_page).to have_selector(table_txt, count: 1)
      header_row_txt = "#{table_txt} tr[id=hole-number-#{values[:tee_id]}]"
      expect(rendered_or_page).to have_selector(header_row_txt, count: 1)
      expect(rendered_or_page).to have_selector("#{header_row_txt} td[id=hole-number-heading-#{values[:tee_id]}]",
                                                count: 1, text: 'Number:')
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 'Out', 10, 11, 12, 13, 14, 15, 16, 17, 18, 'In', 'Total'].each do |num|
        expect(rendered_or_page).to have_selector("#{header_row_txt} td[id=hole-number-#{num}]",
                                                  count: 1, text: num)
      end
      strokes_cell(rendered_or_page, :max_strokes, 'Max Strokes:', values, true, table_txt)
      strokes_cell(rendered_or_page, :avg_strokes, 'Avg Strokes:', values, false, table_txt)
      strokes_cell(rendered_or_page, :min_strokes, 'Min Strokes:', values, true, table_txt)

      putts_row_txt = "#{table_txt} tr[id=putts-#{values[:tee_id]}]"
      expect(rendered_or_page).to have_selector(putts_row_txt, count: 1)
      values[:avg_putts].each_with_index do |num, index|
        expect(rendered_or_page).to have_selector("#{putts_row_txt} td[id=putts-#{index}]",
                                                  count: 1, text: num)
      end
    end

    def strokes_cell(rendered_or_page, sym, header, values, expect_golf_term, pre_css = '')
      row_css = "#{pre_css} tr[id=#{sym}-#{values[:tee_id]}]"
      expect(rendered_or_page).to have_selector(row_css, count: 1)
      expect(rendered_or_page).to have_selector("#{row_css} td[id=#{sym}-heading-#{values[:tee_id]}]",
                                                count: 1, text: header)
      expected_golf_terms = expect_golf_term ? values["#{sym}_golf_term".to_sym] : []
      values[sym].each_with_index do |num, index|
        if expect_golf_term
          golf_term = expected_golf_terms[index]
          td_css = "#{row_css} td[id=#{sym}-#{index}][title='#{golf_term}']" unless golf_term.empty?
          td_css = "#{row_css} td[id=#{sym}-#{index}]" if golf_term.empty?
          expect(rendered_or_page).to have_selector(td_css,
                                                    count: 1, text: num)
        else
          expect(rendered_or_page).to have_selector("#{row_css} td[id=#{sym}-#{index}]",
                                                    count: 1, text: num)
        end
      end
    end

    def expect_show_subheadings(rendered_or_page, values, fieldset_subheading)
      expect(rendered_or_page).to have_selector("#{fieldset_subheading}h2", count: 1, text: "Course: #{values[:course_name]}")
      expect(rendered_or_page).to have_selector("#{fieldset_subheading}h2", count: 1, text: "Tee: #{values[:tee_color]}")
    end

    def expect_edit_subheadings(rendered_or_page, values, fieldset_subheading)
      MethodCommon.expect_subheading_course_name(rendered_or_page, values[:course_name], fieldset_subheading)
      MethodCommon.expect_subheading_tee_color(rendered_or_page, values[:tee_color], fieldset_subheading)
    end

    def expect_editable_field_values_score(rendered_or_page, values, fieldset_form_txt)
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Score::STROKES,
                                         'score_strokes',
                                         values[:strokes],
                                         false,
                                         fieldset_form_txt,
                                         values[:gir].nil? ? nil : "strokes-cell-#{values[:gir]}")
      MethodCommon.expect_have_field_num(rendered_or_page,
                                         Label::Score::PUTTS,
                                         'score_putts',
                                         values[:putts],
                                         false,
                                         fieldset_form_txt)
      MethodCommon.expect_have_field_text(rendered_or_page,
                                          Label::Score::PENALTIES,
                                          'score_penalties',
                                          values[:penalties],
                                          false,
                                          fieldset_form_txt)
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
        clazz = "#{id_string}-cell"
        clazz = "#{id_string}-cell-#{score.green_in_regulation}" if id_string == 'strokes'
        replace_values.each do |replace_info|
          value = replace_info[method_name] if hole.number == replace_info[:hole_number]
          replace_gir = hole.number == replace_info[:hole_number] && method_name == :strokes && !replace_info[:gir].nil?
          clazz = "#{id_string}-cell-#{replace_info[:gir]}" if replace_gir
        end
        in_out_tot += value if keep_totals
        total += value if keep_totals
        expect(rendered_or_page).to have_selector("td[id=hole-#{id_string}-#{score.id}][class='#{clazz}']", count: 1, text: value)
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
