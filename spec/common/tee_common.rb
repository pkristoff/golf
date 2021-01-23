module TeeCommon

  def expect_tee_form_fields(page_or_rendered, tees, values)

    if tees.empty?
      expect(page_or_rendered).to have_selector('p', count: 1, text: 'No tees')
    else
      # Check table headers
      expect(page_or_rendered).to have_selector('table', count: 1)
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
      expect(page_or_rendered).to have_field('Color', disabled: false, text: values[:color])
      expect(page_or_rendered).to have_field('Slope', disabled: false, text: values[:slope])
      expect(page_or_rendered).to have_field('Rating', disabled: false, text: values[:rating])
      expect(page_or_rendered).to have_selector("input[id=number_of_holes][value=#{values[:number_of_holes]}]", count: 1)
      # expect(page_or_rendered).to have_field('Number of holes', disabled: false, text: values[:number_of_holes])
    else
      expect(find_field('Color').value).to eq(values[:color])
      expect(find_field('Slope').value).to eq(values[:slope])
      expect(find_field('Rating').value).to eq(values[:rating])
      expect(find_field('Number of holes').value).to eq(values[:number_of_holes])
    end

    expect(page_or_rendered).to have_button('Create Tee')
    expect(page_or_rendered).to have_button('Edit Course')

  end
end
