require "rails_helper"

describe Restaurant, type: :model  do

  it { is_expected.to have_many(:votes) }
  it { is_expected.to have_many(:games) }
  it { is_expected.to have_many(:round_2_votes).class_name('Vote') }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_least(4).is_at_most(100) }

end
