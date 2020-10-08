class UserChange < ApplicationRecord
  belongs_to :user

  def self.list_changes(start_date, end_date)
    sql_old = <<-SQL.squish
        SELECT old
          FROM user_changes
         WHERE created_at BETWEEN :start_date AND :end_date
           AND uc.user_id = user_id
           AND uc.field = field
      ORDER BY created_at ASC
         LIMIT 1
    SQL
    sql_new = <<-SQL.squish
        SELECT new
          FROM user_changes
         WHERE created_at BETWEEN :start_date AND :end_date
           AND uc.user_id = user_id
           AND uc.field = field
      ORDER BY created_at DESC
         LIMIT 1
    SQL
    sql = <<-SQL.squish
        SELECT field, (#{sql_old}) AS old, (#{sql_new}) AS new
          FROM user_changes uc
         WHERE created_at BETWEEN :start_date AND :end_date
      GROUP BY user_id, field
    SQL

    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([sql, start_date: start_date, end_date: end_date])
    )
  end

  def as_json(options = nil)
    super({ only: %i[field old new] }.merge(options || {}))
  end
end
