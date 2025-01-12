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
    @db[:monthly_cost].select(:id, :name, :value).all do |row|
      results.append(MonthlyCost.new(row[:id], row[:name], row[:value]))
    end

    return results
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
      :name,
      :note,
      :measure_type,
      :price,
      :base_width,
      :base_length
    ]
    results = []
    @db[:material].select(*columns).all do |row|
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
end
