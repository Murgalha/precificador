require 'sequel'
require_relative 'models'

Sequel.extension :migration

class DatabaseHandle
  def initialize(connection_string)
    @connection_string = connection_string
    @db = Sequel.sqlite(@connection_string)
    @migrations_path = File.join(['src', 'database', 'migrations'])

    if !Sequel::Migrator.is_current? @db, @migrations_path
      Sequel::Migrator.run(@db, @migrations_path, :use_transactions => true)
    end
  end

  def add_cost(name, value)
    @db[:monthly_cost].insert(name: name, value: value)
  end

  def get_costs()
    results = []
    @db[:monthly_cost].select(:id, :name, :value).order(Sequel.lit('LOWER(name)')).all do |row|
      results.append(MonthlyCost.new(row[:id], row[:name], row[:value]))
    end

    return results
  end

  def get_cost(cost_id)
    record = @db[:monthly_cost].select(:id, :name, :value).where(:id => cost_id).first

    if record == nil
      return nil
    end

    return MonthlyCost.new(record[:id], record[:name], record[:value])
  end

  def update_cost(data)
    values = {
      :name => data[:name],
      :value => data[:value],
    }

    @db[:monthly_cost].where(:id => data[:id]).update(values)
  end

  def remove_cost(cost_id)
    @db[:monthly_cost].where(:id => cost_id).delete
  end

  def get_salary_info()
    columns = [
      :salary,
      :sunday,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday
    ]

    row = @db[:salary_info].select(*columns)
            .order_by(:id)
            .single_record!

    salary = Salary.new(row[:salary])
    week_hash = [
      WorkDay.sunday(row[:sunday]),
      WorkDay.monday(row[:monday]),
      WorkDay.tuesday(row[:tuesday]),
      WorkDay.wednesday(row[:wednesday]),
      WorkDay.thursday(row[:thursday]),
      WorkDay.friday(row[:friday]),
      WorkDay.saturday(row[:saturday]),
    ]

    return SalaryInfo.new(salary, WorkWeek.new(week_hash))
  end

  def update_salary_info(new_salary, week_hash)
    values = week_hash.clone
    values[:salary] = new_salary

    @db[:salary_info].update(values)
  end

  def get_materials
    columns = [
      :id,
      :name,
      :note,
      :measure_type,
      :price,
      :base_width,
      :base_length
    ]
    results = []
    @db[:material].select(*columns).order(Sequel.lit('LOWER(name)')).all do |row|
      id = row[:id]
      name = row[:name]
      note = row[:note]
      mt = MaterialMeasureType.from_value(row[:measure_type])
      price = row[:price]
      bw = if mt == MaterialMeasureType.area then row[:base_width] else nil end
      bl = if mt == MaterialMeasureType.area then row[:base_length] else nil end

      results.append(Material.new(id, name, note, mt, price, bw, bl))
    end

    return results
  end

  def get_material(material_id)
    columns = [
      :id,
      :name,
      :note,
      :measure_type,
      :price,
      :base_width,
      :base_length
    ]

    record = @db[:material].select(*columns).where(:id => material_id).first

    if record == nil
      return nil
    end

    id = record[:id]
    name = record[:name]
    note = record[:note]
    mt = MaterialMeasureType.from_value(record[:measure_type])
    price = record[:price]
    bw = if mt == MaterialMeasureType.area then record[:base_width] else nil end
    bl = if mt == MaterialMeasureType.area then record[:base_length] else nil end

    return Material.new(id, name, note, mt, price, bw, bl)
  end

  def add_material(name, note, type, price, bw, bl)
    base_width = if type == MaterialMeasureType.area.value then bw else nil end
    base_length = if type == MaterialMeasureType.area.value then bl else nil end

    values = {
      :name => name,
      :note => note,
      :measure_type => type,
      :price => price,
      :base_width => base_width,
      :base_length => base_length,
    }

    @db[:material].insert(values)
  end

  def remove_material(material_id)
    @db[:material].where(:id => material_id).delete
  end

  def update_material(data)
    values = {
      :name => data[:name],
      :note => data[:note],
      :price => data[:price],
      :base_width => data[:base_width],
      :base_length => data[:base_length],
    }

    @db[:material].where(:id => data[:id]).update(values)
  end

  def get_products_summary
    results = []
    @db[:product].select(:id, :name, :description).order(Sequel.lit('LOWER(name)')).all do |row|
      id = row[:id]
      name = row[:name]
      description = row[:description]

      results.append(ProductSummary.new(id, name, description))
    end

    return results
  end

  def get_product(product_id)
    product_result = @db[:product].select(:id, :name, :description, :minutes_needed, :profit)
        .where(:id => product_id)
        .first

    if product_result == nil
      return nil
    end

    material_cols = [
      Sequel.qualify(:material, :id).as(:material_id),
      Sequel.qualify(:material, :name),
      Sequel.qualify(:material, :price),
      Sequel.qualify(:material, :measure_type),
      Sequel.qualify(:material, :base_width),
      Sequel.qualify(:material, :base_length),
      Sequel.qualify(:product_materials, :id).as(:product_material_id),
    ]
    product_id_col = Sequel.qualify(:product, :id)
    pm_product_id_col = Sequel.qualify(:product_materials, :product_id)
    pm_material_id_col = Sequel.qualify(:product_materials, :material_id)
    material_id_col = Sequel.qualify(:material, :id)

    query = @db[:product]
              .join_table(:left, :product_materials, product_id_col => pm_product_id_col)
              .join_table(:left, :material, pm_material_id_col => material_id_col)
              .select(*material_cols)
              .where(:product_id => product_id)
              .order(:product_material_id)

    product_materials = []
    query.each do |row|
      pm_id = row[:product_material_id]
      quantities = @db[:product_material_quantities].select(:quantity).where(:product_material_id => pm_id).all

      if row[:measure_type] == MaterialMeasureType.area.value
        product_materials.append(AreaProductMaterial.new(pm_id, row[:name], row[:price], row[:base_length], row[:base_width], quantities[0][:quantity], quantities[1][:quantity]))
      elsif row[:measure_type] == MaterialMeasureType.length.value
        product_materials.append(LengthProductMaterial.new(pm_id, row[:name], row[:price], quantities[0][:quantity]))
      else
        product_materials.append(UnitProductMaterial.new(pm_id, row[:name], row[:price], quantities[0][:quantity]))
      end
    end

    Product.new(product_result[:id], product_result[:name], product_result[:description], product_result[:minutes_needed], product_result[:profit], product_materials)
  end

  def add_product(data)
    values = {
      :name => data[:name],
      :description => data[:description],
      :minutes_needed => data[:work_time],
      :profit => data[:profit],
    }

    product_id = @db[:product].insert(values)

    for material in data[:materials]
      name = material[0]
      quantity = material[1]

      record = @db[:material].select(:id, :measure_type).where(:name => name).single_record!

      material_id = record[:id]
      material_type = record[:measure_type]

      quantities = []
      if material_type == MaterialMeasureType.area.value
        split = quantity.split('x')
        quantities.append(split[0])
        quantities.append(split[1])
      else
        quantities.append(quantity)
      end

      values = {
        :product_id => product_id,
        :material_id => material_id,
      }
      inserted_id = @db[:product_materials].insert(values)

      for q in quantities
        values = {
          :product_material_id => inserted_id,
          :quantity => q,
        }
        @db[:product_material_quantities].insert(values)
      end
    end
  end

  def edit_product(product_id, new_data)
    values = {
      :name => new_data[:name],
      :description => new_data[:description],
      :minutes_needed => new_data[:work_time],
      :profit => new_data[:profit],
    }
    @db[:product].where(id: product_id).update(values)

    # Deleting old data
    product_materials = @db[:product_materials]
                          .where(product_id: product_id)
                          .select(:id).all

    pm_ids = product_materials.map { |x| x[:id] }
    prod_mat_q = @db[:product_material_quantities]
                   .where(:product_material_id => pm_ids)
                   .select(:id).all
    pmq_ids = prod_mat_q.map { |x| x[:id] }

    @db[:product_material_quantities].where(:id => pmq_ids).delete
    @db[:product_materials].where(:id => pm_ids).delete

    # Inserting updated material data
    for material in new_data[:materials]
      material_id = material[0]
      quantity = material[1]

      record = @db[:material].select(:measure_type).where(:id => material_id).single_record!
      material_type = record[:measure_type]

      quantities = []
      if material_type == MaterialMeasureType.area.value
        split = quantity.split('x')
        quantities.append(split[0])
        quantities.append(split[1])
      else
        quantities.append(quantity)
      end

      values = {
        :product_id => product_id,
        :material_id => material_id,
      }
      inserted_id = @db[:product_materials].insert(values)

      for q in quantities
        values = {
          :product_material_id => inserted_id,
          :quantity => q,
        }
        @db[:product_material_quantities].insert(values)
      end
    end
  end
end
