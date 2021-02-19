module HoleCommon

  require 'views/helpers'

  def expect_hole_form_fields(page_or_rendered, tee, create_update, values)
    holes = tee.sorted_holes
    new_edit = create_update == 'Update' ? Label::Common::EDIT : Label::Common::NEW
    expect(rendered).to have_selector('h1', count: 1, text: "#{new_edit} hole:")
    expect(rendered).to have_selector('h2', count: 1, text: 'Course: George')
    expect(rendered).to have_selector('h2', count: 1, text: "Tee: #{tee.color}")
    expect(rendered).to have_selector('h2', count: 1, text: "Hole: #{values[:number]}")

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
      expect(page_or_rendered).to have_selector("input[id=hole_number][value=#{values[:number]}]")
      expect(page_or_rendered).to have_selector("input[id=hole_yardage][value=#{values[:yardage]}]")
      expect(page_or_rendered).to have_selector("input[id=hole_par][value=#{values[:par]}]")
      expect(page_or_rendered).to have_selector("input[id=hole_hdcp][value=#{values[:hdcp]}]")
    else
      expect(find_field(Label::Hole::NUMBER).value).to eq(values[:number])
      expect(find_field(Label::Hole::YARDAGE).value).to eq(values[:yardage])
      expect(find_field(Label::Hole::PAR).value).to eq(values[:par])
      expect(find_field(Label::Hole::HDCP).value).to eq(values[:hdcp])
    end

    expect(page_or_rendered).to have_button("#{create_update} Hole", count: 1)
    expect(page_or_rendered).to have_button(Button::Tee::EDIT, count: 1)
    expect(page_or_rendered).to have_button(Button::Course::EDIT, count: 1)
    expect(page_or_rendered).to have_button(Button::Course::SHOW_COURSES, count: 1)
  end

  def expect_holes(page_or_rendered, holes, hole_values, replace_values = [])
    # count = 4 for each tee
    expect(page_or_rendered).to have_selector('p', count: 4, text: 'No holes') if hole_values.empty?
    hole_values.each_with_index do |hole_info, index|
      next nil if hole_info[0].nil?

      i = index < 10 ? index : index - 1
      hole_id = holes[i].id
      hole_number_id = "td[id=hole-number-#{hole_id}]"
      hole_number_link_id = "a[id=hole-number-link-#{hole_id}]"
      number_text = hole_info[0].to_s
      yardage_text = hole_info[1]
      par_text = hole_info[2]
      hdcp_text = hole_info[3]
      replace_values.each do |replace_info|
        yardage_text = replace_info[:yardage] if replace_info[:number] == number_text
        par_text = replace_info[:par] if replace_info[:number] == number_text
        hdcp_text = replace_info[:hdcp] if replace_info[:number] == number_text
      end
      # puts "i=#{i} hole_number_id=#{hole_number_id}"
      # puts "hole_info=#{hole_info} hole_number=#{holes[i].number}"
      expect(page_or_rendered).to have_selector(hole_number_id, count: 1, text: "#{number_text}")
      expect(page_or_rendered).to have_selector(hole_number_link_id, count: 1, text: "#{number_text}")
      expect(page_or_rendered).to have_selector("td[id=hole-yardage-#{hole_id}]", count: 1, text: "#{yardage_text}")
      expect(page_or_rendered).to have_selector("td[id=hole-par-#{hole_id}]", count: 1, text: "#{par_text}")
      expect(page_or_rendered).to have_selector("td[id=hole-hdcp-#{hole_id}]", count: 1, text: "#{hdcp_text}")
    end
  end

  def expect_form_holes(page_or_rendered, values = {})

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    expect(find_field(Label::Hole::NUMBER).value.to_s).to eq(values[:number])
    expect(find_field(Label::Hole::YARDAGE).value.to_s).to eq(values[:yardage])
    expect(find_field(Label::Hole::PAR).value.to_s).to eq(values[:par])
    expect(find_field(Label::Hole::HDCP).value.to_s).to eq(values[:hdcp])

  end
end
