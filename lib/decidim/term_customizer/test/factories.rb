# frozen_string_literal: true

FactoryBot.define do
  # Create as a sequence to avoid key collisions
  sequence :translation_key do |n|
    "#{::Faker::Lorem.words(number: rand(1..3)).join(".").downcase}.tr#{n}"
  end

  factory :translation_set, class: Decidim::TermCustomizer::TranslationSet do
    transient do
      organization { nil }
    end

    name do
      {
        en: generate(:title),
        fi: generate(:title),
        sv: generate(:title)
      }
    end

    after(:create) do |set, evaluator|
      if evaluator.organization
        set.constraints.create!(
          organization: evaluator.organization
        )
      end
    end
  end

  factory :translation, class: Decidim::TermCustomizer::Translation do
    locale { :en }
    key { generate(:translation_key) }
    value { ::Faker::Lorem.words(number: rand(1..10)).join(" ") }
    translation_set { create(:translation_set) }
  end

  factory :translation_set_constraint, class: Decidim::TermCustomizer::Constraint do
    organization { create(:organization) }
    translation_set { create(:translation_set) }
    subject { create(:participatory_process, organization: organization) }
  end
end
