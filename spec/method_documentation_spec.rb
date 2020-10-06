# frozen_string_literal: true

describe 'method_documentation' do
  def expect_offenses(file, *expected_offenses)
    output = `rubocop #{file}`
    # output = system "rubocop -d #{file}"
    if expected_offenses.empty?
      expect($CHILD_STATUS.success?).to eq(true), "expected rubocop no offenses but got exit code: #{$CHILD_STATUS}"
    else
      expect($CHILD_STATUS.success?).to eq(false), "expected rubocop offenses but got exit code: #{$CHILD_STATUS}"
      actual_offenses = offenses(output)
      actual_offenses.each { |off| puts off } unless expected_offenses.size == actual_offenses.size

      expected_offenses.each_with_index do |off_a, i|
        expect(actual_offenses[i][0]).to eq("#{file}#{off_a[0]}")
        expect(actual_offenses[i][1]).to eq(off_a[1])
        expected_msg = "expected #{expected_offenses.size} offense got #{actual_offenses.size}"
        expect(expected_offenses.size).to eq(actual_offenses.size), expected_msg
      end
    end
  end

  def offenses(output)
    lines = output.split(/\n/)
    begin_offenses = lines.index('Offenses:')
    offs = []
    return offs if begin_offenses.nil?

    i = begin_offenses + 2
    while i < lines.size && i + 3 < lines.size && lines[i + 1].exclude?('file inspected')
      offs.push([lines[i], lines[i + 1]])
      i += 3
    end
    offs
  end
end
