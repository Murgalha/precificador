# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:monthly_cost) do
      primary_key :id
      String :name, null: false, unique: true
      Float :value, null: false
    end
  end
end
