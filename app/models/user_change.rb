class UserChange < ApplicationRecord
  belongs_to :user

  def old_value(start_date, end_date)
    UserChange.where(field: field, created_at: start_date..end_date).first.old
  end

  def new_value(start_date, end_date)
    UserChange.where(field: field, user_id: user_id, created_at: start_date..end_date).last.new
  end

  def self.list_changes(start_date, end_date)
    UserChange.where(created_at: start_date..end_date).group(:user_id, :field).map do |uc|
      {
        'field': uc.field,
        'old': uc.old_value(start_date, end_date),
        'new': uc.new_value(start_date, end_date)
      }
    end
  end

  def as_json(options = nil)
    super({ only: %i[field old new] }.merge(options || {}))
  end
end
