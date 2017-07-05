# Backstory

We had a file that used Proc.new to make a call out to a model to perform an action. We recently sweeped our factories w/Rubocop, which suggested we use `proc` vs `Proc.new` [based on this rule](http://batsov.com/articles/2014/02/04/the-elements-of-style-in-ruby-number-12-proc-vs-proc-dot-new/) and enforced in [this cop](https://github.com/bbatsov/ruby-style-guide#proc).

Seems reasonable, but the language parsing in factory girl doesn't harass the stabby syntax `->`, or if it recognizes that it's a class instantiation `Proc.new`, but it does freak out if it's `lambda` or `proc`, I'm assuming because it parses it as a named phrase instead of kicking it out as a reserved word.

```
= proc
= lambda
= throw
```

Seems to treat these words as attributes instead of reserved words not to use. It breaks on linting, but for the same reason as listed below in the doesn't work section. If it's stabby, it's fine, if it's Proc.new, it's fine, if it's the named words all lowercase it breaks. 

All tested with with FG 4.8 and Ruby 2.4.

# Works (new 1.9 lambda syntax)

```
add_school_role = -> (user, role) { School.find_or_create_by!(name: "Funtimes University").add_user(user, role) }

trait :school_admin do
  after(:create) { |user| add_school_role.call(user, :admin) }
end
```

# Works (but 1.8 style code)

```
add_school_role = Proc.new do |user, role|
  School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
end

trait :school_admin do
  after(:create) { |user| add_school_role.call(user, :admin) }
end
```

# Works (using a method)

```
FactoryGirl.define do
  factory :user do
    trait :school_admin do
      after(:create) { |user| add_school_role.call(user, :admin) }
    end
  end
end

def add_school_role(user, role)
  School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
end
```

# Doesn't Work (using 1.9 lambda syntax v. 1.9 stabby syntax)

```
add_school_role = lambda do |user, role|
  School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
end

trait :school_admin do
  after(:create) { |user| add_school_role.call(user, :admin) }
end
```

Error is (first vs. thereafter):
```
 NoMethodError:
   undefined method `lambda=' for #<User id: nil, created_at: nil, updated_at: nil>
FactoryGirl::AttributeDefinitionError:
  Attribute already defined: lambda
```

# Doesn't Work (using 1.9 proc v 1.8 Proc.new)

add_school_role = proc do |user, role|
  School.find_or_create_by!(name: "Funtimes University").add_user(user, role)
end

trait :school_admin do
  after(:create) { |user| add_school_role.call(user, :admin) }
end

Error is (first vs. thereafter):
```
 NoMethodError:
   undefined method `proc=' for #<User id: nil, created_at: nil, updated_at: nil>

FactoryGirl::AttributeDefinitionError:
  Attribute already defined: proc
```

