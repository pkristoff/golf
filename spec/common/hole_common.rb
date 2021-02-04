module HoleCommon

  def expect_hole_form_fields(page_or_rendered, holes, create_update, values)
    new_edit = create_update == 'Update' ? 'Edit' : 'New'
    expect(rendered).to have_selector('h2', count: 1, text: "#{new_edit} hole:")
    expect(rendered).to have_selector('h3', count: 1, text: 'Course: George')
    expect(rendered).to have_selector('h3', count: 1, text: 'Tee: Black')

    if holes.empty?
      expect(page_or_rendered).to have_selector('p', count: 1, text: 'No holes')
    else
      # Check table headers
      expect(page_or_rendered).to have_selector('table', count: 1)
      expect(page_or_rendered).to have_selector('th[id=holes-number]', count: 1, text: 'Number')
      expect(page_or_rendered).to have_selector('th[id=holes-yardage]', count: 1, text: 'Yardage')
      expect(page_or_rendered).to have_selector('th[id=holes-par]', count: 1, text: 'Par')
      expect(page_or_rendered).to have_selector('th[id=holes-hdcp]', count: 1, text: 'HDCP')

      holes.each do |hole|
        expect(page_or_rendered).to have_selector("tr[id=hole-#{hole.id}]", count: 1)
        expect(page_or_rendered).to have_selector("td[id=hole-number-#{hole.id}]", count: 1, text: hole.number)
        expect(page_or_rendered).to have_selector("td[id=hole-yardage-#{hole.id}]", count: 1, text: hole.yardage)
        expect(page_or_rendered).to have_selector("td[id=hole-par-#{hole.id}]", count: 1, text: hole.par)
        expect(page_or_rendered).to have_selector("td[id=hole-hdcp-#{hole.id}]", count: 1, text: hole.hdcp)
      end

    end

    if page_or_rendered.is_a? String
      # expect(page_or_rendered).to have_field('Number', disabled: false, text: values[:number])
      expect(page_or_rendered).to have_selector("input[id=hole_number][value=#{values[:number]}]")
      expect(page_or_rendered).to have_selector("input[id=hole_yardage][value=#{values[:yardage]}]")
      expect(page_or_rendered).to have_selector("input[id=hole_par][value=#{values[:par]}]")
      expect(page_or_rendered).to have_selector("input[id=hole_hdcp][value=#{values[:hdcp]}]")
      # expect(page_or_rendered).to have_field('Yardage', disabled: false, text: values[:yardage])
      # expect(page_or_rendered).to have_field('Par', disabled: false, text: values[:par])
      # expect(page_or_rendered).to have_field('HDCP', disabled: false, text: values[:hdcp])
    else
      expect(find_field('Number').value).to eq(values[:color])
      expect(find_field('Yardage').value).to eq(values[:slope])
      expect(find_field('Par').value).to eq(values[:rating])
      expect(find_field('HDCP').value).to eq(values[:hdcp])
    end

    expect(page_or_rendered).to have_button("#{create_update} Hole")
    expect(page_or_rendered).to have_button('Edit Tee')
    expect(page_or_rendered).to have_button('Edit Course')

  end
end
