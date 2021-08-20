describe 'PerformanceCourse' do
  before do
    @round = FactoryBot.create(:round)
  end

  after do
    # Do nothing
  end

  context 'Average strokes' do
    it 'Returns empty array if no rounds' do
      tee = @round.tee
      expect(tee.rounds.size).to eq(1)
      course = tee.course
      @round.destroy
      pc = PerformanceCourse.new(tee.rounds, course.number_of_holes)
      expect(tee.rounds.size).to eq(0)
      pc_average_strokes = pc.average_strokes_with_totals
      expect(pc_average_strokes.size).to eq(21)
      expect(pc_average_strokes[0]).to eq(0)
    end

    it 'Returns strokes round for one round' do
      tee = @round.tee
      course = tee.course
      pc = PerformanceCourse.new(tee.rounds, course.number_of_holes)
      pc_average = pc.average_strokes_with_totals
      expect(pc_average.size).to eq(21)
      TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO].each_with_index do |score_info, index|
        expect(pc_average[index]).to eq(score_info[1])
      end
    end
    it 'Returns ave strokes round for two round' do
      tee = @round.tee
      course = tee.course
      round2 = FactoryBot.create(:round, tee: tee, round_score_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO_2])
      expect(tee).to eq(round2.tee)
      pc = PerformanceCourse.new(tee.rounds, course.number_of_holes)
      expected_averages = [6, 5, 4, 6, 4, 5, 4, 6, 6, 46, 4, 3, 6, 5, 6, 5, 5, 5, 4, 43, 89]
      pc_average = pc.average_strokes_with_totals
      expected_averages.each_with_index do |strokes, index|
        expect(pc_average[index]).to eq(strokes)
      end
    end
  end

  context 'Average putts' do
    it 'Returns empty array if no rounds' do
      tee = @round.tee
      expect(tee.rounds.size).to eq(1)
      course = tee.course
      @round.destroy
      pc = PerformanceCourse.new(tee.rounds, course.number_of_holes)
      expect(tee.rounds.size).to eq(0)
      pc_average_putts = pc.average_putts_with_totals
      expect(pc_average_putts.size).to eq(21)
      expect(pc_average_putts[0]).to eq(0)
    end
    it 'Returns putts round for one round' do
      tee = @round.tee
      course = tee.course
      pc = PerformanceCourse.new(tee.rounds, course.number_of_holes)
      pc_average_putts = pc.average_putts_with_totals
      expect(pc_average_putts.size).to eq(21)
      TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO].each_with_index do |score_info, index|
        expect(pc_average_putts[index]).to eq(score_info[2])
      end
    end
    it 'Returns avg putts round for two round' do
      tee = @round.tee
      course = tee.course
      round2 = FactoryBot.create(:round, tee: tee, round_score_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO_2])
      expect(tee).to eq(round2.tee)
      pc = PerformanceCourse.new(tee.rounds, course.number_of_holes)
      expected_averages = [1, 2, 2, 3, 3, 2, 2, 3, 3, 21, 2, 1, 1, 2, 3, 1, 2, 2, 1, 15, 36]
      pc_average_putts = pc.average_putts_with_totals
      expected_averages.each_with_index do |putts, index|
        expect(pc_average_putts[index]).to eq(putts)
      end
    end
  end
end