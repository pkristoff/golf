# frozen_string_literal: true

# Controller for handling CRUD for Score
#
class ScoresController < ApplicationController
  # Edit a Score
  #
  def edit
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @round = Round.find(params[:round_id])
    @score = Score.find(params[:id])
  end

  # Show tees for given @course
  #
  def index; end

  # Update a Score
  #
  def update
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @round = Round.find(params[:round_id])
    @score = Score.find(params[:id])
    @score.update(score_params)
    if @score.errors.any?
      flash.now[:alert] = 'Error updating score'
    else
      flash[:notice] = 'score updated'
      @score = @round.next_score(@score)
    end
    render 'scores/edit'
  end

  private

  def score_params
    params.require(:score).permit(:id, :strokes, :putts, :penalties)
  end
end
