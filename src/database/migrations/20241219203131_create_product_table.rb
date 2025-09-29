# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:product) do
      primary_key :id
      String :name, null: false, unique: true
      String :description, text: true, null: true
      Integer :minutes_needed, null: false
      Integer :profit, null: false
    end
  end
end
