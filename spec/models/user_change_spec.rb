require 'rails_helper'

RSpec.describe UserChange, type: :model do
  it { should belong_to(:user) }
end