# frozen_string_literal: true

require 'common/application_common'
require 'common/button_to_common'

module HoleCommon
  class << self
    include RSpec::Matchers
    include Capybara::RSpecMatchers
    include Capybara::Node::Finders
    # include Capybara::Queries::TextQuery
    require 'views/helpers'
    include AsideCommon
    include DatabaseCommon
    include ButtonToCommon

    def expect_edit_hole(page_or_rendered, tee, values)
      AsideCommon.expect_aside(page_or_rendered, values[:show_tees]) unless page_or_rendered.is_a?(String)
      DatabaseCommon.expect_database(page_or_rendered) unless page_or_rendered.is_a?(String)

      expect_hole_heading(page_or_rendered, 'Edit hole:', values[:course_name], values[:tee_color], values[:number])

      HoleCommon.expect_holes_list(page_or_rendered, tee, values)

      expect_edit_hole_fields(page_or_rendered, false, values)

      expect(page_or_rendered).to have_button('Update Hole', count: 1)

      expect_hole_edit_other_buttons(page_or_rendered)
    end

    def expect_new_hole(page_or_rendered, tee, values)
      AsideCommon.expect_aside(page_or_rendered, values[:show_tees]) unless page_or_rendered.is_a?(String)
      DatabaseCommon.expect_database(page_or_rendered) unless page_or_rendered.is_a?(String)
      expect_hole_heading(page_or_rendered, 'New hole:', values[:course_name], values[:tee_color], values[:number])

      HoleCommon.expect_holes_list(page_or_rendered, tee, values)

      expect_edit_hole_fields(page_or_rendered, true, values)
      expect(page_or_rendered).not_to have_button('Create Hole')

      expect_hole_edit_other_buttons(page_or_rendered)
    end

    def expect_holes_list(page_or_rendered, tee, values)
      holes = tee.sorted_holes
      if holes.empty?
        expect(page_or_rendered).to have_selector('p', count: 1, text: 'No holes')
      else
        replace_values = values[:replace_values].nil? ? [] : values[:replace_values]
        expect_holes_table(page_or_rendered, holes, tee, values, replace_values)
      end
    end

    private

    def expect_holes_table(page_or_rendered, sorted_holes, tee, values, replace_values = [])
      expect_table_heading(page_or_rendered, tee, values)
      expect_hole_info(page_or_rendered, replace_values, sorted_holes, values)
      expect_hole_values(page_or_rendered, replace_values, sorted_holes)
    end

    def expect_hole_values(page_or_rendered, replace_values, sorted_holes)
      sorted_holes.each do |hole|
        hole_number_id = "td[id=hole-number-#{hole.id}]"
        hole_number_link_id = "a[id=hole-number-link-#{hole.id}]"
        number_text = hole.number
        yardage_text = hole.yardage
        par_text = hole.par
        hdcp_text = hole.hdcp
        replace_values.each do |replace_info|
          replacable = replace_info[:number].to_s == number_text.to_s
          yardage_text = replace_info[:yardage] if replacable
          par_text = replace_info[:par] if replacable
          hdcp_text = replace_info[:hdcp] if replacable
        end
        expect(page_or_rendered).to have_selector(hole_number_id, count: 1, text: number_text)
        expect(page_or_rendered).to have_selector(hole_number_link_id, count: 1, text: number_text)
        expect(page_or_rendered).to have_selector("td[id=hole-yardage-#{hole.id}]", count: 1, text: yardage_text)
        expect(page_or_rendered).to have_selector("td[id=hole-par-#{hole.id}]", count: 1, text: par_text)
        expect(page_or_rendered).to have_selector("td[id=hole-hdcp-#{hole.id}]", count: 1, text: hdcp_text)
      end
    end

    def expect_hole_info(page_or_rendered, replace_values, sorted_holes, values)
      hole_values = values[:hole_values].nil? ? [] : values[:hole_values]
      hole_values.each_with_index do |hole_info, index|
        next nil if hole_info[0].nil?

        i = index < 10 ? index : index - 1
        hole_id = sorted_holes[i].id
        hole_number_id = "td[id=hole-number-#{hole_id}]"
        hole_number_link_id = "a[id=hole-number-link-#{hole_id}]"
        number_text = hole_info[0].to_s
        yardage_text = hole_info[1]
        par_text = hole_info[2]
        hdcp_text = hole_info[3]
        replace_values.each do |replace_info|
          replacable = replace_info[:number].to_s == number_text
          yardage_text = replace_info[:yardage] if replacable
          par_text = replace_info[:par] if replacable
          hdcp_text = replace_info[:hdcp] if replacable
        end
        expect(page_or_rendered).to have_selector(hole_number_id, count: 1, text: number_text)
        expect(page_or_rendered).to have_selector(hole_number_link_id, count: 1, text: number_text)
        expect(page_or_rendered).to have_selector("td[id=hole-yardage-#{hole_id}]", count: 1, text: yardage_text)
        expect(page_or_rendered).to have_selector("td[id=hole-par-#{hole_id}]", count: 1, text: par_text)
        expect(page_or_rendered).to have_selector("td[id=hole-hdcp-#{hole_id}]", count: 1, text: hdcp_text)
      end
    end

    def expect_table_heading(page_or_rendered, tee, values)
      expect(page_or_rendered).to have_selector("table[id=holes-#{tee.id}]", count: 1)

      expect(page_or_rendered).to have_selector("td[id=hole-number-heading-#{tee.id}]", count: 1, text: 'Number')
      expect(page_or_rendered).to have_selector("td[id=hole-yardage-heading-#{tee.id}]", count: 1, text: Label::Hole::YARDAGE)
      expect(page_or_rendered).to have_selector("td[id=hole-par-heading-#{tee.id}]", count: 1, text: Label::Hole::PAR)
      expect(page_or_rendered).to have_selector("td[id=hole-hdcp-heading-#{tee.id}]", count: 1, text: Label::Hole::HDCP)

      expect(page_or_rendered).to have_selector("tr[id=hole-number-#{tee.id}]", count: 1)
      expect(page_or_rendered).to have_selector("tr[id=hole-yardage-#{tee.id}]", count: 1)
      expect(page_or_rendered).to have_selector("tr[id=hole-par-#{tee.id}]", count: 1)
      expect(page_or_rendered).to have_selector("tr[id=hole-hdcp-#{tee.id}]", count: 1)

      expect(page_or_rendered).to have_selector("td[id=total-out-yardage-#{tee.id}]", count: 1, text: values[:total_out_yardage])
      expect(page_or_rendered).to have_selector("td[id=total-in-yardage-#{tee.id}]", count: 1, text: values[:total_in_yardage])
      expect(page_or_rendered).to have_selector("td[id=total-yardage-#{tee.id}]", count: 1, text: values[:total_yardage])
    end

    def expect_hole_edit_other_buttons(page_or_rendered)
      expect_button_within_course_fieldset(page_or_rendered,
                                           [Button::Course::EDIT, Button::Course::NEW, Button::Tee::NEW, Button::Tee::EDIT])
      expect_button_within_round_fieldset(page_or_rendered, [])
    end

    def expect_edit_hole_fields(page_or_rendered, is_disabled, values)
      AsideCommon.expect_aside(page_or_rendered, values[:show_tees]) unless page_or_rendered.is_a?(String)
      expect(page_or_rendered).to have_selector('fieldset', count: 1, text: Fieldset::Holes::HOLE)
      disabled = is_disabled ? '[disabled=disabled]' : ''
      # rubocop:disable Layout/LineLength
      expect(page_or_rendered).to have_selector("fieldset input[id=hole_number][disabled=disabled][value=#{values[:number]}]", count: 1)
      expect(page_or_rendered).to have_selector("fieldset input[id=hole_yardage]#{disabled}[value=#{values[:yardage]}]", count: 1)
      expect(page_or_rendered).to have_selector("fieldset input[id=hole_par]#{disabled}[value=#{values[:par]}]", count: 1)
      expect(page_or_rendered).to have_selector("fieldset input[id=hole_hdcp]#{disabled}[value=#{values[:hdcp]}]", count: 1)

      expect(page_or_rendered).to have_field(Label::Hole::NUMBER, disabled: true, count: 1) unless page_or_rendered.is_a? String
      expect(page_or_rendered).to have_field(Label::Hole::YARDAGE, disabled: is_disabled, count: 1) unless page_or_rendered.is_a? String
      expect(page_or_rendered).to have_field(Label::Hole::PAR, disabled: is_disabled, count: 1) unless page_or_rendered.is_a? String
      expect(page_or_rendered).to have_field(Label::Hole::HDCP, disabled: is_disabled, count: 1) unless page_or_rendered.is_a? String
      # rubocop:enable Layout/LineLength
    end

    def expect_hole_heading(page_or_rendered, page_heading, course_name, tee_color, number)
      expect(page_or_rendered).to have_selector('h1', count: 1, text: page_heading)
      expect(page_or_rendered).to have_selector('h2', count: 1, text: "Course: #{course_name}")
      expect(page_or_rendered).to have_selector('h2', count: 1, text: "Tee: #{tee_color}")
      expect(page_or_rendered).to have_selector('h2', count: 1, text: "Hole: #{number}")
    end
  end
end
