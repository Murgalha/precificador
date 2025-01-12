Sequel.migration do
  change do
    create_table(:product_materials) do
      primary_key :id
      foreign_key :product_id, :product
      foreign_key :material_id, :material
    end

    create_table(:product_material_quantities) do
      primary_key :id
      foreign_key :product_material_id, :product_materials
      Float :quantity, null: false
    end
  end
end
