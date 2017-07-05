FactoryGirl.define do
  factory :user do
    # works
    # add_school_role = Proc.new do |user, role|
    #   School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
    # end

    # works
    # add_school_role = -> (user, role) { School.find_or_create_by!(name: "Funtimes University").add_user(user, role) }

    # doesn't work (rubocop enforced)
    # add_school_role = lambda do |user, role|
    #   School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
    # end

    # doesn't work (rubocop enforced)
    add_school_role = proc do |user, role|
      School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
    end


    trait :school_admin do
      after(:create) { |user| add_school_role.call(user, :admin) }
    end
  end
end

# works
# def add_school_role(user, role)
#   School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
# end