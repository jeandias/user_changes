class UsersController < ApplicationController
  before_action :set_user, only: %i[register_changes]
  include Compare

  def register_changes
    diff.each do |change|
      @user.user_changes << UserChange.new(change)
    end
  end

  def list_changes
    start_date = Date.parse(date_params[:start_date])
    end_date = Date.parse(date_params[:end_date])

    result = UserChange.list_changes(start_date, end_date)

    render json: result, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:id, old: {}, new: {})
  end

  def date_params
    params.require(:start_date)
    params.require(:end_date)
    params.permit(:start_date, :end_date)
  end

  def set_user
    @user = User.find(user_params[:id])
  end
end
