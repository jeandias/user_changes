class User < ApplicationRecord
  has_many :user_changes, dependent: :destroy
end
