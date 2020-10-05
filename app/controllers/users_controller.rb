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

    sub_query = <<-SQL.squish
        SELECT new
          FROM user_changes
         WHERE created_at BETWEEN :start_date AND :end_date
           AND uc.user_id = user_id
           AND uc.field = field
      ORDER BY created_at DESC
         LIMIT 1
    SQL
    sql = <<-SQL.squish
        SELECT field, old, (#{sub_query}) AS new
          FROM user_changes uc
         WHERE created_at BETWEEN :start_date AND :end_date
      GROUP BY user_id, field
    SQL
    result = ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([sql, start_date: start_date, end_date: end_date])
    )

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
