# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'welcome/index.html.erb', type: :view do
  it 'Welcome page' do
    render
    expect(rendered).to have_selector("a[id='show_golf_courses']", text: 'Show golf courses')
  end
end
