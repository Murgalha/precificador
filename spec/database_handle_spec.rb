require "rspec"
require_relative "../src/database/database_handle"

describe "#add_cost" do
  it "should add cost with correct data" do
    handle = DatabaseHandle.new(":memory:")
    handle.add_cost("test name", "test value")

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
      cost = costs[0]

      expect(costs).not_to be_empty
      expect(costs.size).to eq(1)
      expect(cost.name).to eq(expected_name)
      expect(cost.value).to eq(expected_value)
    end
  end
end
