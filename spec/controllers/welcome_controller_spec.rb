# frozen_string_literal: true

describe WelcomeController, type: :controller do
  it 'clear db' do
    Account.create(name: 'Paul', handicap_index: 0.0)
    FactoryBot.create(:round)
    put :clear_db
    expect(flash[:notice]).to eq('DB cleared')
  end
end
