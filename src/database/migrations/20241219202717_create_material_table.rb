Sequel.migration do
  change do
    create_table(:material) do
      primary_key :id
      String :name, null: false, unique: true
      String :note, text: true, null: false
      Integer :measure_type, null: false
      Float :price, null: false
      Integer :base_width, null: true
      Integer :base_length, null: true
    end
  end
end
