# frozen_string_literal: true

module TeeCommon
  def expect_tee_form_fields(page_or_rendered, tees, values, update_create)
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    new_edit = update_create == 'Update' ? 'Edit' : 'New'

    expect(page_or_rendered).to have_selector('h1', count: 1, text: "#{new_edit} tee:")
    expect(page_or_rendered).to have_selector('h2', count: 1, text: 'Course: George')
    expect(page_or_rendered).to have_selector('h2', count: 1, text: "Tee: #{values[:number]}")

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
      end

    end

    if page_or_rendered.is_a? String
      expect(page_or_rendered).to have_field(Label::Tee::COLOR, disabled: false, text: values[:color])
      expect(page_or_rendered).to have_field(Label::Tee::SLOPE, disabled: false, text: values[:slope])
      expect(page_or_rendered).to have_field(Label::Tee::RATING, disabled: false, text: values[:rating])
      expect(page_or_rendered).to have_selector("input[id=number_of_holes][value=#{values[:number_of_holes]}]", count: 1)
    else
      expect(find_field(Label::Tee::COLOR).value).to eq(values[:color])
      expect(find_field(Label::Tee::SLOPE).value).to eq(values[:slope])
      expect(find_field(Label::Tee::RATING).value).to eq(values[:rating])
      expect(find_field('Number of holes').value).to eq(values[:number_of_holes])
    end

    expect(page_or_rendered).to have_button("#{update_create} Tee")
    expect(page_or_rendered).to have_button(Button::Course::EDIT)
    expect(page_or_rendered).to have_button(Button::Course::SHOW_COURSES)
  end
end
