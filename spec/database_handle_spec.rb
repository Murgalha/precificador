require "rspec"
require_relative "../src/database/database_handle"

RSpec.describe DatabaseHandle do
  describe "#add_cost" do
    it "should add cost with correct data" do
      handle = DatabaseHandle.new(":memory:")
      handle.add_cost("test name", 1.0)

      costs = handle.get_costs

      expect(costs).not_to be_empty
      expect(costs.size).to eq(1)
    end
  end

  describe "#get_costs" do
    context "when no cost was added" do
      it "returns empty list" do
        handle = DatabaseHandle.new(":memory:")
        costs = handle.get_costs

        expect(costs).to be_empty
      end
    end

    context "when cost exists" do
      it "returns data" do
        handle = DatabaseHandle.new(":memory:")

        expected_name = "test name"
        expected_value = 1.2
        handle.add_cost(expected_name, expected_value)

        costs = handle.get_costs

        expect(costs).not_to be_empty
        expect(costs.size).to eq(1)

        cost = costs[0]
        expect(cost.name).to eq(expected_name)
        expect(cost.value).to eq(expected_value)
      end
    end
  end

  describe "#add_product" do
    it "saves data" do
      handle = DatabaseHandle.new(":memory:")

      handle.add_material("material 1", "", MaterialMeasureType.unit.value, 1.2, nil, nil)

      product_data = {
        :name => "test product",
        :description => "test description",
        :work_time => 60,
        :profit => 50,
        :materials => [["material 1", 5]]
      }
      handle.add_product(product_data)
      product = handle.get_product 1

      expect(product.name).to eq "test product"
      expect(product.description).to eq "test description"
      expect(product.minutes_needed).to eq 60
      expect(product.profit).to eq 50

      expect(product.materials.size).to eq(1)
      material = product.materials[0]
      expect(material.is_a? UnitProductMaterial).to be_truthy
      expect(material.name).to eq("material 1")
      expect(material.quantity).to eq(5)
    end
  end

  describe "#edit_product" do
    it "saves new data and remove old material data" do
      handle = DatabaseHandle.new(":memory:")

      handle.add_material("material 1", "", MaterialMeasureType.unit.value, 1.2, nil, nil)
      handle.add_material("material 2", "", MaterialMeasureType.area.value, 1.0, 100, 120)

      product_data = {
        :name => "test product",
        :description => "",
        :work_time => 60,
        :profit => 50,
        :materials => [["material 1", "5"]]
      }
      handle.add_product(product_data)

      new_data = {
        :name => "new test product name",
        :description => "fancy description",
        :work_time => 3,
        :profit => 1,
        :materials => [[2, "10x9"]]
      }
      handle.edit_product(1, new_data)

      product = handle.get_product 1

      expect(product.name).to eq("new test product name")
      expect(product.description).to eq("fancy description")
      expect(product.minutes_needed).to eq(3)
      expect(product.profit).to eq(1)

      expect(product.materials.size).to eq(1)

      material = product.materials[0]
      expect(material.is_a? AreaProductMaterial).to be_truthy
      expect(material.name).to eq("material 2")
      expect(material.width).to eq(10)
      expect(material.length).to eq(9)
    end
  end
end
