# frozen_string_literal: true

require 'rspec'
require_relative '../src/database/database_handle'

RSpec.describe DatabaseHandle do
  describe '#add_cost' do
    it 'should add cost with correct data' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_cost('test name', 1.0)

      costs = handle.query_costs

      expect(costs).not_to be_empty
      expect(costs.size).to eq(1)
    end
  end

  describe '#query_costs' do
    context 'when no cost was added' do
      it 'returns empty list' do
        handle = DatabaseHandle.new(':memory:')
        costs = handle.query_costs

        expect(costs).to be_empty
      end
    end

    context 'when cost exists' do
      it 'returns data' do
        handle = DatabaseHandle.new(':memory:')

        expected_name = 'test name'
        expected_value = 1.2
        handle.add_cost(expected_name, expected_value)

        costs = handle.query_costs

        expect(costs).not_to be_empty
        expect(costs.size).to eq(1)

        cost = costs[0]
        expect(cost.name).to eq(expected_name)
        expect(cost.value).to eq(expected_value)
      end

      it 'should sort by case insensitive name' do
        handle = DatabaseHandle.new(':memory:')
        handle.add_cost('B2 cost', 1.0)
        handle.add_cost('A cost', 1.0)
        handle.add_cost('b1 cost', 1.0)

        costs = handle.query_costs

        expect(costs.size).to eq 3
        expect(costs[0].name).to eq 'A cost'
        expect(costs[1].name).to eq 'b1 cost'
        expect(costs[2].name).to eq 'B2 cost'
      end
    end
  end

  describe '#query_cost' do
    it 'returns nil when id is not existent' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_cost('cost 1', 1.0)
      handle.add_cost('cost 2', 1.5)

      cost = handle.query_cost 4

      expect(cost).to be_nil
    end

    it 'returns correct data when id is correct' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_cost('cost 1', 1.0)
      handle.add_cost('cost 2', 1.5)

      cost = handle.query_cost 2

      expect(cost.name).to eq 'cost 2'
      expect(cost.value).to eq 1.5
    end
  end

  describe '#update_cost' do
    it 'should save all updated data' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_cost('cost 1', 1.0)

      handle.update_cost({ id: 1, name: 'new cost name', value: 123 })

      cost = handle.query_cost 1

      expect(cost.name).to eq 'new cost name'
      expect(cost.value).to eq 123
    end
  end

  describe '#query_salary_info' do
    it 'always returns data' do
      handle = DatabaseHandle.new(':memory:')
      salary_info = handle.query_salary_info

      expect(salary_info.salary.value).to eq 0
      expect(salary_info.work_week.sunday.work_time).to eq 0
      expect(salary_info.work_week.sunday.name).to eq :sunday

      expect(salary_info.work_week.monday.work_time).to eq 0
      expect(salary_info.work_week.monday.name).to eq :monday

      expect(salary_info.work_week.tuesday.work_time).to eq 0
      expect(salary_info.work_week.tuesday.name).to eq :tuesday

      expect(salary_info.work_week.wednesday.work_time).to eq 0
      expect(salary_info.work_week.wednesday.name).to eq :wednesday

      expect(salary_info.work_week.thursday.work_time).to eq 0
      expect(salary_info.work_week.thursday.name).to eq :thursday

      expect(salary_info.work_week.friday.work_time).to eq 0
      expect(salary_info.work_week.friday.name).to eq :friday

      expect(salary_info.work_week.saturday.work_time).to eq 0
      expect(salary_info.work_week.saturday.name).to eq :saturday
    end
  end

  describe '#update_salary_info' do
    it 'saves data correctly' do
      handle = DatabaseHandle.new(':memory:')
      week_hash = {
        sunday: 9,
        monday: 7,
        tuesday: 4,
        wednesday: 56,
        thursday: 100,
        friday: 235,
        saturday: 343
      }
      salary = 1000

      handle.update_salary_info(salary, week_hash)
      salary_info = handle.query_salary_info

      expect(salary_info.salary.value).to eq salary
      expect(salary_info.work_week.sunday.work_time).to eq week_hash[:sunday]
      expect(salary_info.work_week.monday.work_time).to eq week_hash[:monday]
      expect(salary_info.work_week.tuesday.work_time).to eq week_hash[:tuesday]
      expect(salary_info.work_week.wednesday.work_time).to eq week_hash[:wednesday]
      expect(salary_info.work_week.thursday.work_time).to eq week_hash[:thursday]
      expect(salary_info.work_week.friday.work_time).to eq week_hash[:friday]
      expect(salary_info.work_week.saturday.work_time).to eq week_hash[:saturday]
    end
  end

  describe '#query_materials' do
    context 'when no cost was added' do
      it 'returns empty list' do
        handle = DatabaseHandle.new(':memory:')
        materials = handle.query_materials

        expect(materials).to be_empty
      end
    end

    context 'when material exists' do
      it 'returns data' do
        handle = DatabaseHandle.new(':memory:')

        exp_name = 'test name'
        exp_note = 'this is a note'
        exp_type = MaterialMeasureType.area.value
        exp_price = 3.2
        exp_bw = 7
        exp_bl = 13
        handle.add_material(exp_name, exp_note, exp_type, exp_price, exp_bw, exp_bl)

        materials = handle.query_materials

        expect(materials).not_to be_empty
        expect(materials.size).to eq 1

        material = materials[0]
        expect(material.name).to eq(exp_name)
        expect(material.note).to eq(exp_note)
        expect(material.measure_type.value).to eq(exp_type)
        expect(material.price).to eq(exp_price)
        expect(material.base_width).to eq(exp_bw)
        expect(material.base_length).to eq(exp_bl)
      end

      it 'should sort by case insensitive name' do
        handle = DatabaseHandle.new(':memory:')

        note = 'this is a note'
        type = MaterialMeasureType.area.value
        price = 3.2
        bw = 7
        bl = 13
        handle.add_material('B2 material', note, type, price, bw, bl)
        handle.add_material('A material', note, type, price, bw, bl)
        handle.add_material('b1 material', note, type, price, bw, bl)

        materials = handle.query_materials

        expect(materials.size).to eq 3
        expect(materials[0].name).to eq 'A material'
        expect(materials[1].name).to eq 'b1 material'
        expect(materials[2].name).to eq 'B2 material'
      end
    end
  end

  describe '#query_material' do
    it 'returns nil when id is not existent' do
      handle = DatabaseHandle.new(':memory:')
      note = 'this is a note'
      type = MaterialMeasureType.area.value
      price = 3.2
      bw = 7
      bl = 13
      handle.add_material('material 1', note, type, price, bw, bl)
      handle.add_material('material 2', note, type, price, bw, bl)

      material = handle.query_material 4

      expect(material).to be_nil
    end

    it 'returns correct data when id is correct' do
      handle = DatabaseHandle.new(':memory:')
      note = 'this is a note'
      type = MaterialMeasureType.area.value
      price = 3.2
      bw = 7
      bl = 13
      handle.add_material('material 1', note, type, price, bw, bl)
      handle.add_material('material 2', note, type, price, bw, bl)

      material = handle.query_material 2

      expect(material.name).to eq 'material 2'
      expect(material.note).to eq(note)
      expect(material.measure_type.value).to eq(type)
      expect(material.price).to eq(price)
      expect(material.base_width).to eq(bw)
      expect(material.base_length).to eq(bl)
    end
  end

  describe '#add_material' do
    it 'saves it to the database' do
      handle = DatabaseHandle.new(':memory:')
      note = 'this is a note'
      type = MaterialMeasureType.area.value
      price = 3.2
      bw = 7
      bl = 13

      handle.add_material('material 1', note, type, price, bw, bl)
      material = handle.query_material 1

      expect(material.name).to eq 'material 1'
      expect(material.note).to eq(note)
      expect(material.measure_type.value).to eq(type)
      expect(material.price).to eq(price)
      expect(material.base_width).to eq(bw)
      expect(material.base_length).to eq(bl)
    end
  end

  describe '#remove_material' do
    it 'removes the material from the database' do
      handle = DatabaseHandle.new(':memory:')
      note = 'this is a note'
      type = MaterialMeasureType.area.value
      price = 3.2
      bw = 7
      bl = 13

      handle.add_material('material 1', note, type, price, bw, bl)

      handle.remove_material 1

      material = handle.query_material 1
      materials = handle.query_materials

      expect(material).to be_nil
      expect(materials.size).to eq 0
    end
  end

  describe '#update_material' do
    it 'saves the new data in the database' do
      handle = DatabaseHandle.new(':memory:')
      note = 'this is a note'
      type = MaterialMeasureType.area.value
      price = 3.2
      bw = 7
      bl = 13

      handle.add_material('material 1', note, type, price, bw, bl)
      new_data = {
        id: 1,
        name: 'new name',
        note: 'new note',
        price: 4.5,
        base_width: 1,
        base_length: 3
      }

      handle.update_material new_data
      material = handle.query_material 1

      expect(material.name).to eq 'new name'
      expect(material.note).to eq('new note')
      expect(material.measure_type.value).to eq(type)
      expect(material.price).to eq(4.5)
      expect(material.base_width).to eq(1)
      expect(material.base_length).to eq(3)
    end
  end

  describe '#query_products_summary' do
    context 'when no product was added' do
      it 'returns empty list' do
        handle = DatabaseHandle.new(':memory:')
        products = handle.query_products_summary

        expect(products).to be_empty
      end
    end

    context 'when product exists' do
      it 'returns data' do
        handle = DatabaseHandle.new(':memory:')

        handle.add_material('material 1', '', MaterialMeasureType.unit.value, 1.2, nil, nil)

        product_data = {
          name: 'test product',
          description: 'test description',
          work_time: 60,
          profit: 50,
          materials: [['material 1', 5]]
        }
        handle.add_product(product_data)
        product = handle.query_product 1

        expect(product.id).to eq 1
        expect(product.name).to eq 'test product'
        expect(product.description).to eq 'test description'
      end

      it 'should sort by case insensitive name' do
        handle = DatabaseHandle.new(':memory:')
        handle.add_material('material 1', '', MaterialMeasureType.unit.value, 1.2, nil, nil)

        product_data = {
          description: 'test description',
          work_time: 60,
          profit: 50,
          materials: [['material 1', 5]]
        }

        product_data[:name] = 'B2 product'
        handle.add_product(product_data)

        product_data[:name] = 'A product'
        handle.add_product(product_data)

        product_data[:name] = 'b1 product'
        handle.add_product(product_data)

        products = handle.query_products_summary

        expect(products.size).to eq 3
        expect(products[0].name).to eq 'A product'
        expect(products[1].name).to eq 'b1 product'
        expect(products[2].name).to eq 'B2 product'
      end
    end
  end

  describe '#query_product' do
    it 'returns nil when id is not existent' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_material('material 1', '', MaterialMeasureType.unit.value, 1.2, nil, nil)

      product_data = {
        name: 'test product',
        description: 'test description',
        work_time: 60,
        profit: 50,
        materials: [['material 1', 5]]
      }

      handle.add_product(product_data)
      product = handle.query_product 3

      expect(product).to be_nil
    end

    it 'returns correct data when id is correct' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_material('material 1', '', MaterialMeasureType.unit.value, 1.2, nil, nil)

      product_data = {
        name: 'test product',
        description: 'test description',
        work_time: 60,
        profit: 50,
        materials: [['material 1', 5]]
      }

      handle.add_product(product_data)
      product = handle.query_product 1

      expect(product.id).to eq 1
      expect(product.name).to eq 'test product'
      expect(product.description).to eq 'test description'
    end

    it 'sorts materials by id' do
      handle = DatabaseHandle.new(':memory:')
      handle.add_material('A material', '', MaterialMeasureType.unit.value, 1.2, nil, nil)
      handle.add_material('B material', '', MaterialMeasureType.unit.value, 1.2, nil, nil)

      product_data = {
        name: 'test product',
        description: 'test description',
        work_time: 60,
        profit: 50,
        materials: [['B material', 5], ['A material', 5]]
      }

      handle.add_product(product_data)
      product = handle.query_product 1

      expect(product.materials.size).to eq 2
      expect(product.materials[0].name).to eq 'B material'
      expect(product.materials[1].name).to eq 'A material'
    end
  end

  describe '#add_product' do
    it 'saves data' do
      handle = DatabaseHandle.new(':memory:')

      handle.add_material('material 1', '', MaterialMeasureType.unit.value, 1.2, nil, nil)

      product_data = {
        name: 'test product',
        description: 'test description',
        work_time: 60,
        profit: 50,
        materials: [['material 1', 5]]
      }
      handle.add_product(product_data)
      product = handle.query_product 1

      expect(product.name).to eq 'test product'
      expect(product.description).to eq 'test description'
      expect(product.minutes_needed).to eq 60
      expect(product.profit).to eq 50

      expect(product.materials.size).to eq(1)
      material = product.materials[0]
      expect(material.is_a?(UnitProductMaterial)).to be_truthy
      expect(material.name).to eq('material 1')
      expect(material.quantity).to eq(5)
    end
  end

  describe '#edit_product' do
    it 'saves new data and remove old material data' do
      handle = DatabaseHandle.new(':memory:')

      handle.add_material('material 1', '', MaterialMeasureType.unit.value, 1.2, nil, nil)
      handle.add_material('material 2', '', MaterialMeasureType.area.value, 1.0, 100, 120)

      product_data = {
        name: 'test product',
        description: '',
        work_time: 60,
        profit: 50,
        materials: [['material 1', '5']]
      }
      handle.add_product(product_data)

      new_data = {
        name: 'new test product name',
        description: 'fancy description',
        work_time: 3,
        profit: 1,
        materials: [[2, '10x9']]
      }
      handle.edit_product(1, new_data)

      product = handle.query_product 1

      expect(product.name).to eq('new test product name')
      expect(product.description).to eq('fancy description')
      expect(product.minutes_needed).to eq(3)
      expect(product.profit).to eq(1)

      expect(product.materials.size).to eq(1)

      material = product.materials[0]
      expect(material.is_a?(AreaProductMaterial)).to be_truthy
      expect(material.name).to eq('material 2')
      expect(material.width).to eq(10)
      expect(material.length).to eq(9)
    end
  end
end
