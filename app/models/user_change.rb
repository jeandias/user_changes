class UserChange < ApplicationRecord
  belongs_to :user

  def as_json(options = nil)
    super({ only: %i[field old new] }.merge(options || {}))
  end
end
