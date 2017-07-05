require "rails_helper"

describe User do
  let(:school_admin) { FactoryGirl.create(:user, :school_admin)}

  it 'creates a school admin properly' do
    school_admin
  end
end
