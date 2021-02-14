module HoleCommon

  require 'views/helpers'

  def expect_hole_form_fields(page_or_rendered, holes, create_update, values)
    new_edit = create_update == 'Update' ? Label::Common::EDIT : Label::Common::NEW
    expect(rendered).to have_selector('h1', count: 1, text: "#{new_edit} hole:")
    expect(rendered).to have_selector('h2', count: 1, text: 'Course: George')
    expect(rendered).to have_selector('h2', count: 1, text: 'Tee: Black')

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
      # expect(page_or_rendered).to have_field('Yardage', disabled: false, text: values[:yardage])
      # expect(page_or_rendered).to have_field('Par', disabled: false, text: values[:par])
      # expect(page_or_rendered).to have_field('HDCP', disabled: false, text: values[:hdcp])
    else
      expect(find_field(Label::Hole::NUMBER).value).to eq(values[:number])
      expect(find_field(Label::Hole::YARDAGE).value).to eq(values[:yardage])
      expect(find_field(Label::Hole::PAR).value).to eq(values[:par])
      expect(find_field(Label::Hole::HDCP).value).to eq(values[:hdcp])
    end

    expect(page_or_rendered).to have_button("#{create_update} Hole")
    expect(page_or_rendered).to have_button(Button::Tee::EDIT)
    expect(page_or_rendered).to have_button(Button::Course::EDIT)
  end

  def expect_holes(page_or_rendered, holes, hole_values)
    # count = 4 for each tee
    expect(page_or_rendered).to have_selector('p', count: 4, text: 'No holes') if hole_values.empty?
    hole_values.each_with_index do |hole_info, index|
      next nil if hole_info[0].nil?

      i = index < 10 ? index : index - 1
      hole_id = holes[i].id
      hole_number_id = "td[id=hole-number-#{hole_id}]"
      hole_number_link_id = "a[id=hole-number-link-#{hole_id}]"
      # puts "i=#{i} hole_number_id=#{hole_number_id}"
      # puts "hole_info=#{hole_info} hole_number=#{holes[i].number}"
      expect(page_or_rendered).to have_selector(hole_number_id, count: 1, text: "#{hole_info[0]}")
      expect(page_or_rendered).to have_selector(hole_number_link_id, count: 1, text: "#{hole_info[0]}")
    end
  end

  def expect_form_holes(page_or_rendered, values={})

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    expect(find_field(Label::Hole::NUMBER).value.to_s).to eq(values[:number])
    expect(find_field(Label::Hole::YARDAGE).value.to_s).to eq(values[:yardage])
    expect(find_field(Label::Hole::PAR).value.to_s).to eq(values[:par])
    expect(find_field(Label::Hole::HDCP).value.to_s).to eq(values[:hdcp])

  end
end
