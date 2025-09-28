# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:salary_info) do
      primary_key :id
      Float :salary, null: false
      Integer :sunday, null: false
      Integer :monday, null: false
      Integer :tuesday, null: false
      Integer :wednesday, null: false
      Integer :thursday, null: false
      Integer :friday, null: false
      Integer :saturday, null: false
    end
  end
end
