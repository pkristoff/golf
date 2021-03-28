# frozen_string_literal: true

# 1st page
class WelcomeController < ApplicationController
  # show page for upload .xslx
  #
  def filein_db; end

  # upload ,xslx file
  #
  def upload
    uploaded_filepath = params[:file].path
    GolfReader.new(uploaded_filepath)
    flash[:notice] = 'DB updated'
    render 'index'
  end

  # index
  #
  def index
    # just fall through
  end
end
