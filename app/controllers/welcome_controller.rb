# frozen_string_literal: true

# 1st page
#
class WelcomeController < ApplicationController
  # show page for upload .xslx
  #
  def filein_db; end

  # clean out DB
  #
  def clear_db
    begin
      DbStuff.clear_db
    rescue StandardError => e
      flash[:alert] = "Error while clearing db: #{e.message}"
    else
      flash[:notice] = t('flash.notice.db.cleared')
    end
    render 'index'
  end

  # upload ,xslx file
  #
  def upload
    begin
      uploaded_filepath = params[:file].path
      DbStuff.load_in_db(uploaded_filepath)
    rescue StandardError => e
      flash[:alert] = t('flash.notice.db.updated', message: e.message)
    else
      flash[:notice] = t('flash.notice.db.updated')
    end
    render 'index'
  end

  # index
  #
  def index
    # just fall through
  end
end
