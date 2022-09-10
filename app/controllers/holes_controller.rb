# frozen_string_literal: true

# Controller for handling CRUD for tee
#
class HolesController < ApplicationController
  # Creation of a new golf course tee
  #
  def create
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @hole = @tee.holes.create(tee_params)
    if @tee.errors.any?
      flash.now[:alert] = t('flash.alert.hole.creating')
      render 'holes/new'
    else
      flash[:notice] = t('flash.notice.hole.created')
      render 'holes/edit'
    end
  end

  # Creation of a new golf course tee
  #
  def edit
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @hole = Hole.find(params[:id])
  end

  # Creation of a new golf course hole
  #
  def new
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @hole = Hole.new
  end

  # update of a golf course hole
  #
  def update
    @course = Course.find(params[:course_id])
    @tee = Tee.find(params[:tee_id])
    @hole = Hole.find(params[:id])
    @hole.update(hole_params)
    if @hole.errors.any?
      flash.now[:alert] = t('flash.alert.hole')
    else
      flash[:notice] = t('flash.notice.hole.updated')
      @hole = @tee.next_hole(@hole)
    end
    render 'holes/edit'
  end

  private

  def hole_params
    params.require(:hole).permit(:id, :number, :yardage, :par, :hdcp)
  end
end
