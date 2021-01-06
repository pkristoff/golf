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
    expect(find_field(Label::Course::NAME).value).to eq(name)
    expect(find_field(Label::Course::STREET1).value).to eq(street1)
    expect(find_field(Label::Course::STREET2).value).to eq(street2)
    expect(find_field(Label::Course::CITY).value).to eq(city)
    expect(find_field(Label::Course::STATE).value).to eq(state)
    expect(find_field(Label::Course::ZIP).value).to eq(zip)
  end
end