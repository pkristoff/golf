# frozen_string_literal: true

# expect messages
#
def expect_messages(messages, rendered_page = page)
  ids = messages.map { |mp| mp[0] }
  %i[flash_alert flash_notice error_explanation].each do |my_id|
    expect(rendered_page).not_to have_selector("div[id=#{my_id}]") unless ids.include? my_id
  end

  messages.each do |message_pair|
    id = message_pair[0]
    count = nil
    count = message_pair[2] if id == :error_explanation && message_pair.size == 3
    message = message_pair[1]
    if id == :error_explanation && message.is_a?(Array)
      expect(rendered_page).to have_selector("div[id=#{id}] h2", text: message[0])
      (1..message.size).each do |i|
        expect(rendered_page).to have_selector("div[id=#{id}] li", text: message[i])
      end
      # rubocop:disable Layout/LineLength
      expect(message.size).to eq(count + 1), "Number of expected error messages expected=#{count + 1} but got #{message.size}" unless count.nil?
      # rubocop:enable Layout/LineLength
    else
      expect(rendered_page).to have_selector("div[id=#{id}]", text: message) unless id.nil?
    end
  end
end
