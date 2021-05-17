# frozen_string_literal: true

require 'common/application_common'

module TeeCommon
  include AsideCommon
  include DatabaseCommon

  def expect_tee_form_fields(page_or_rendered, tees, values, update_create)
    expect_aside(page_or_rendered, values[:show_tees]) unless page_or_rendered.is_a?(String)
    expect_database(page_or_rendered) unless page_or_rendered.is_a?(String)
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    new_edit = update_create == 'Update' ? 'Edit' : 'New'

    expect(page_or_rendered).to have_selector('h1', count: 1, text: "#{new_edit} tee:")
    expect(page_or_rendered).to have_selector('h2', count: 1, text: 'Course: George')
    expect(page_or_rendered).to have_selector('h2', count: 1, text: "Tee: #{values[:number]}")

    expect_tees(page_or_rendered, tees)

    if page_or_rendered.is_a? String
      expect(page_or_rendered).to have_field(Label::Tee::COLOR, disabled: false, text: values[:color])
      expect(page_or_rendered).to have_field(Label::Tee::SLOPE, disabled: false, text: values[:slope])
      expect(page_or_rendered).to have_field(Label::Tee::RATING, disabled: false, text: values[:rating])
    else
      expect(find_field(Label::Tee::COLOR).value).to eq(values[:color])
      expect(find_field(Label::Tee::SLOPE).value).to eq(values[:slope])
      expect(find_field(Label::Tee::RATING).value).to eq(values[:rating])
    end

    expect(page_or_rendered).to have_button("#{update_create} Tee")
    expect(page_or_rendered).to have_button(Button::Course::EDIT)
    expect(page_or_rendered).to have_button(Button::Tee::NEW) if update_create == 'Update'
  end

  def expect_tees_page(page_or_rendered, course, tees, show_tees)
    include AsideCommon unless page_or_rendered.is_a?(String)
    include DatabaseCommon unless page_or_rendered.is_a?(String)
    expect_aside(page_or_rendered, show_tees) unless page_or_rendered.is_a?(String)
    expect_database(page_or_rendered) unless page_or_rendered.is_a?(String)

    expect(page_or_rendered).to have_selector('h1', count: 1, text: "Pick Tee for course: #{course.name}")

    expect_tees(page_or_rendered, tees)
  end

  private

  def expect_tees(page_or_rendered, tees)
    if tees.empty?
      expect(page_or_rendered).to have_selector('p', count: 1, text: 'No tees')
    else
      # Check table headers
      expect(page_or_rendered).to have_selector('table[id=tees]', count: 1)
      expect(page_or_rendered).to have_selector('th[id=tees-color]', count: 1, text: 'Color')
      expect(page_or_rendered).to have_selector('th[id=tees-slope]', count: 1, text: 'Slope')
      expect(page_or_rendered).to have_selector('th[id=tees-rating]', count: 1, text: 'Rating')

      tees.each do |tee|
        expect(page_or_rendered).to have_selector("tr[id=tee-#{tee.id}]", count: 1)
        expect(page_or_rendered).to have_selector("td[id=tee-color-#{tee.id}]", count: 1, text: tee.color)
        expect(page_or_rendered).to have_selector("td[id=tee-slope-#{tee.id}]", count: 1, text: tee.slope)
        expect(page_or_rendered).to have_selector("td[id=tee-rating-#{tee.id}]", count: 1, text: tee.rating)

        expect(page_or_rendered).to have_selector("td[id=hole-number-heading-#{tee.id}]", count: 1, text: 'Number:')
        expect(page_or_rendered).to have_selector("td[id=hole-yardage-heading-#{tee.id}]", count: 1, text: 'Yardage:')
        expect(page_or_rendered).to have_selector("td[id=hole-par-heading-#{tee.id}]", count: 1, text: 'Par:')
        expect(page_or_rendered).to have_selector("td[id=hole-hdcp-heading-#{tee.id}]", count: 1, text: 'HDCP:')
        tee.sorted_holes.each do |hole|
          # rubocop:disable Layout/LineLength
          expect(page_or_rendered).to have_selector("tr[id=hole-number-#{tee.id}] td[id=hole-number-#{hole.id}]", count: 1, text: hole.number)
          expect(page_or_rendered).to have_selector("tr[id=hole-yardage-#{tee.id}] td[id=hole-yardage-#{hole.id}]", count: 1, text: hole.yardage)
          expect(page_or_rendered).to have_selector("tr[id=hole-par-#{tee.id}] td[id=hole-par-#{hole.id}]", count: 1, text: hole.par)
          expect(page_or_rendered).to have_selector("tr[id=hole-hdcp-#{tee.id}] td[id=hole-hdcp-#{hole.id}]", count: 1, text: hole.hdcp)
          # rubocop:enable Layout/LineLength
        end
      end

    end
  end
end
