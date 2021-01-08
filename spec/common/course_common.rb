module CourseCommon
  def expect_new_fields_with_values(page, name, street1, street2, city, state, zip)
    expect(page).to have_selector('h1', text: 'New Course')
    expect(find_button('submit-course')).to be_truthy
    expect(find_field(Label::Course::NAME).value).to eq(name)
    expect(find_field(Label::Course::STREET1).value).to eq(street1)
    expect(find_field(Label::Course::STREET2).value).to eq(street2)
    expect(find_field(Label::Course::CITY).value).to eq(city)
    expect(find_field(Label::Course::STATE).value).to eq(state)
    expect(find_field(Label::Course::ZIP).value).to eq(zip)
  end

  def expect_validation_errors(invalid_field_names, valid_field_names)
    invalid_field_names.each do |field_name|
      expect(page).to have_selector("div[class=field_with_errors] input[id=#{field_name}]")
    end
    valid_field_names.each do |field_name|
      expect(page).not_to have_selector("div[class=field_with_errors] input[id=#{field_name}]")
    end
  end

  def expect_edit_fields_with_values(page, name, street1, street2, city, state, zip)
    expect(page).to have_selector('h1', text: 'Edit Course')
    expect(find_button('submit-course')).to be_truthy
    expect(find_field(Label::Course::NAME).value).to eq(name)
    expect(find_field(Label::Course::STREET1).value).to eq(street1)
    expect(find_field(Label::Course::STREET2).value).to eq(street2)
    expect(find_field(Label::Course::CITY).value).to eq(city)
    expect(find_field(Label::Course::STATE).value).to eq(state)
    expect(find_field(Label::Course::ZIP).value).to eq(zip)
  end

  def expect_show_fields_with_values(page, name, street1, street2, city, state, zip)
    expect(page).to have_selector('h1', text: 'Show Course')
    expect(find('a', text: Label::Common::EDIT)).to be_truthy
    expect(find('a', text: Label::Common::DESTROY)).to be_truthy
    expect(find_field(Label::Course::NAME, disabled: true).value).to eq(name)
    expect(find_field(Label::Course::STREET1, disabled: true).value).to eq(street1)
    expect(find_field(Label::Course::STREET2, disabled: true).value).to eq(street2)
    expect(find_field(Label::Course::CITY, disabled: true).value).to eq(city)
    expect(find_field(Label::Course::STATE, disabled: true).value).to eq(state)
    expect(find_field(Label::Course::ZIP, disabled: true).value).to eq(zip)
  end

  def expect_form_fields(disabled, values)
    expect(rendered).to have_field('course_name', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_name][value='#{values[:course_name]}']")
    expect(rendered).to have_field('course_address_attributes_street_1', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_street_1][value='#{values[:course_address_attributes_street_1]}']")
    expect(rendered).to have_field('course_address_attributes_street_2', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_street_2][value='#{values[:course_address_attributes_street_2]}']")
    expect(rendered).to have_field('course_address_attributes_city', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_city][value='#{values[:course_address_attributes_city]}']")
    expect(rendered).to have_field('course_address_attributes_state', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_state][value='#{values[:course_address_attributes_state]}']")
    expect(rendered).to have_field('course_address_attributes_zip_code', disabled: disabled)
    expect(rendered).to have_selector("input[id=course_address_attributes_zip_code][value='#{values[:course_address_attributes_zip_code]}']")
  end
end