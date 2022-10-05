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
    @calc_hix_rounds = []
  end

  # update edit page
  #
  def update
    @account = Account.find_by(id: params[:id])
    case params[:commit]
    when I18n.t('button.account.submit')
      @calc_hix_rounds = [] if @calc_hix_rounds.nil?
      if @account.update(account_params)
        render :edit, alert: 'Update successful '
      else
        render :edit, alert: 'Validation error(s).'
      end
    when I18n.t('button.account.calculate_handicap_index')
      logger.info('Starting calc_handicap_index')
      @handicap_index, @initial_hix, @calc_hix_rounds, @score_differentials, @diffs_to_use, @adjustment,
        @avg, @avg_adj, @avg_adj96, @hix = @account.calc_handicap_index
      @account.save!
      logger.info('Ending calc_handicap_index')
      render :edit, alert: "#{I18n.t('button.account.calculate_handicap_index')} successful "
    when I18n.t('button.account.calculate_handicap_index_no_init')
      logger.info('Starting calc_handicap_index')
      @handicap_index, @sorted_round_info_last, @initial_hix,
        @calc_hix_rounds, @score_differentials, @diffs_to_use, @adjustment,
        @avg, @avg_adj, @avg_adj96, @hix = @account.calc_handicap_index(50)
      @account.save!
      logger.info('Ending calc_handicap_index')
      render :edit, alert: "#{I18n.t('button.account.calculate_handicap_index')} successful "
    else
      raise 'Unknown commit'
    end
  end

  private

  def account_params
    params.require(:account)
          .permit(Account.basic_permitted_params
                         .concat([{ address_attributes: Address.basic_permitted_params }]))
  end
end
