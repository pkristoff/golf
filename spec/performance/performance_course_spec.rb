describe 'PerformanceCourse' do
  before do
    # do nothing
  end

  after do
    # Do nothing
  end

  context '18 holes' do
    before do
      @round = FactoryBot.create(:round)
    end
    context 'Average strokes & putts' do
      it 'Returns empty array if no rounds' do
        tee = @round.tee
        expect(tee.rounds.size).to eq(1)
        course = tee.course
        @round.destroy
        pc = PerformanceCourse.new(tee, course.number_of_holes)
        expect(tee.rounds.size).to eq(0)
        pc_average_holes = pc.average_holes
        expect(pc_average_holes.size).to eq(21)
        expect(pc_average_holes[0].title).to eq(1)
      end
      it 'Returns strokes & putts round for one round' do
        tee = @round.tee
        course = tee.course
        pc = PerformanceCourse.new(tee, course.number_of_holes)
        pc_average_holes = pc.average_holes
        expect(pc_average_holes.size).to eq(21)
        TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO].each_with_index do |score_info, index|
          expect(pc_average_holes[index].strokes).to eq(score_info[1])
          expect(pc_average_holes[index].putts).to eq(score_info[2]),
                                                   "Average putts incorrect index=#{index} pc_average_holes[index]=#{pc_average_holes[index]} score_info[2]=#{score_info[2]}"
        end
      end
      it 'Returns ave strokes & putts round for two round' do
        tee = @round.tee
        course = tee.course
        round2 = FactoryBot.create(:round, tee: tee, round_score_info: TeeHoleInfo::HOLE_INFO_LOCHMERE[:BLACK_SCORE_INFO2])
        expect(tee).to eq(round2.tee)
        pc = PerformanceCourse.new(tee, course.number_of_holes)
        pc_average_holes = pc.average_holes
        expected_stroke_avg = [6.5, 5, 4, 6, 4, 5, 4, 6, 6, 46.5, 4, 3, 6, 5, 6, 5, 5, 5, 4.5, 43.5, 90]
        expected_stroke_max = [8, 5, 4, 6, 4, 5, 4, 6, 7, 49, 5, 3, 6, 5, 6, 5, 5, 5, 5, 45, 91]
        expected_stroke_min = [5, 5, 4, 6, 4, 5, 4, 6, 5, 44, 3, 3, 6, 5, 6, 5, 5, 5, 4, 42, 89]
        expected_putt_avg = [1.5, 2, 2, 3, 3, 2, 2, 3, 3, 21.5, 2, 1, 1, 2, 3, 1, 2, 2, 1.5, 15.5, 37]
        pc_average_holes.each_with_index do |average_hole, index|
          expect(average_hole.strokes).to eq(expected_stroke_avg[index]), "stroke mismatch for #{index}: average_hole.strokes: #{average_hole.strokes} does not eq expected_averages[index]: #{expected_stroke_avg[index]}"
          expect(average_hole.max_strokes).to eq(expected_stroke_max[index]), "max stroke mismatch for #{index}: average_hole.max_strokes: #{average_hole.max_strokes} does not eq expected_stroke_max[index]: #{expected_stroke_max[index]}"
          expect(average_hole.min_strokes).to eq(expected_stroke_min[index]), "min stroke mismatch for #{index}: average_hole.min_strokes: #{average_hole.min_strokes} does not eq expected_stroke_min[index]: #{expected_stroke_min[index]}"
          expect(average_hole.putts).to eq(expected_putt_avg[index]), "putt mismatch for #{index}: average_hole.putts: #{average_hole.putts} does not eq expected_putt_avg[index]: #{expected_putt_avg[index]}"
        end
      end
    end
  end
  context '9 holes' do
    before do
      tee = FactoryBot.create(:tee, tee_hole_info: TeeHoleInfo::HOLE_INFO_KN_10_18[:Black])
      @round = FactoryBot.create(:round, tee: tee,
                                 round_score_info: TeeHoleInfo::HOLE_INFO_KN_10_18[:BLACK_SCORE_INFO])
    end
    context 'Average strokes & putts' do
      it 'Returns empty array if no rounds' do
        tee = @round.tee
        expect(tee.rounds.size).to eq(1)
        course = tee.course
        @round.destroy
        pc = PerformanceCourse.new(tee, course.number_of_holes)
        expect(tee.rounds.size).to eq(0)
        pc_average_holes = pc.average_holes
        expect(pc_average_holes.size).to eq(10)
        expect(pc_average_holes[0].putts).to eq(0)
      end
      it 'Returns strokes & putts round for one round' do
        tee = @round.tee
        course = tee.course
        pc = PerformanceCourse.new(tee, course.number_of_holes)
        pc_average_holes = pc.average_holes
        expect(pc_average_holes.size).to eq(10)
        TeeHoleInfo::HOLE_INFO_KN_10_18[:BLACK_SCORE_INFO].each_with_index do |score_info, index|
          expect(pc_average_holes[index].strokes).to eq(score_info[1])
          expect(pc_average_holes[index].max_strokes).to eq(score_info[1])
          expect(pc_average_holes[index].min_strokes).to eq(score_info[1])
          expect(pc_average_holes[index].putts).to eq(score_info[2]),
                                                   "Average putts incorrect index=#{index} pc_average_holes[index]=#{pc_average_holes[index]} score_info[2]=#{score_info[2]}"
        end
      end
      it 'Returns avg strokes & putts round for two round' do
        tee = @round.tee
        course = tee.course
        round2 = FactoryBot.create(:round, tee: tee, round_score_info: TeeHoleInfo::HOLE_INFO_KN_10_18[:BLACK_SCORE_INFO2])
        expect(tee).to eq(round2.tee)
        pc = PerformanceCourse.new(tee, course.number_of_holes)
        pc_average_holes = pc.average_holes
        expected_stroke_avg = [6.5, 5, 4, 6, 4, 5, 4, 6, 6, 46.5]
        expected_stroke_max = [8, 5, 4, 6, 4, 5, 4, 6, 7, 49]
        expected_stroke_min  = [5, 5, 4, 6, 4, 5, 4, 6, 5, 44]
        expected_stroke_avg.each_with_index do |expected_strokes, index|
          avg_hole = pc_average_holes[index]
          expect(avg_hole.strokes).to eq(expected_strokes), "strokes mismatch for #{index}: pc_average_holes[index].strokes: #{pc_average_holes[index].strokes} does not eq strokes: #{expected_strokes}"
          expect(avg_hole.max_strokes).to eq(expected_stroke_max[index]),
                                          "stroke_max mismatch for #{index}: avg_hole.max_strokes: #{avg_hole.max_strokes} does not eq expected_stroke_max[index]: #{expected_stroke_max[index]}"
        end
        expected_putts_avg = [1.5, 2, 2, 3, 3, 2, 2, 3, 3, 21.5]
        expected_putts_avg.each_with_index do |expected_putts, index|
          expect(pc_average_holes[index].putts).to eq(expected_putts), "putts mismatch for #{index}: pc_average_holes[index].putts: #{pc_average_holes[index].putts} does not eq putts: #{expected_putts}"
        end
      end
    end
  end
end