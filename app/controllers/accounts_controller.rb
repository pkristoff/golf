# frozen_string_literal: true

# Accounts controller
#
class AccountsController < ApplicationController
  # show account info
  #
  def index
    @accounts = Account.all
  end

  # setup edit page of account
  #
  def edit
    @account = Account.find_by(id: params[:id])
    @eighteen_hole_rounds = []
  end

  # update edit page
  #
  def update
    @account = Account.find_by(id: params[:id])
    case params[:commit]
    when Button::Account::SUBMIT
      if @account.update(account_params)
        render :edit, alert: 'Update successful '
      else
        render :edit, alert: 'Validation error(s).'
      end
    when Button::Account::CALCUATE_HANDICAP_INDEX
      logger.info('Starting calc_handicap_index')
      @account.calc_handicap_index
      logger.info('Ending calc_handicap_index')
      @eighteen_hole_rounds = Account.find_18_hole_rounds.sort_by(&:date)
      render :edit, alert: "#{Button::Account::CALCUATE_HANDICAP_INDEX} successful "
    else
      raise
    end
  end

  private

  def account_params
    params.require(:account)
          .permit(Account.basic_permitted_params
                         .concat([{ address_attributes: Address.basic_permitted_params }]))
  end
end
