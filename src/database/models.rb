# frozen_string_literal: true

class MonthlyCost
  attr_accessor :id, :name, :value

  def initialize(id, name, value)
    @id = id
    @name = name
    @value = value
  end
end

class Salary
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class SalaryInfo
  attr_accessor :salary, :work_week

  def initialize(salary, work_week)
    @salary = salary
    @work_week = work_week
  end
end

class WorkWeek
  attr_reader :days

  def initialize(days)
    @days = days
  end

  def sunday
    @days.filter { |x| x.name == :sunday }.first
  end

  def monday
    @days.filter { |x| x.name == :monday }.first
  end

  def tuesday
    @days.filter { |x| x.name == :tuesday }.first
  end

  def wednesday
    @days.filter { |x| x.name == :wednesday }.first
  end

  def thursday
    @days.filter { |x| x.name == :thursday }.first
  end

  def friday
    @days.filter { |x| x.name == :friday }.first
  end

  def saturday
    @days.filter { |x| x.name == :saturday }.first
  end
end

class WorkDay
  attr_reader :name, :work_time

  private_class_method :new

  def self.sunday(work_time)
    new(:sunday, work_time)
  end

  def self.monday(work_time)
    new(:monday, work_time)
  end

  def self.tuesday(work_time)
    new(:tuesday, work_time)
  end

  def self.wednesday(work_time)
    new(:wednesday, work_time)
  end

  def self.thursday(work_time)
    new(:thursday, work_time)
  end

  def self.friday(work_time)
    new(:friday, work_time)
  end

  def self.saturday(work_time)
    new(:saturday, work_time)
  end

  def ==(other)
    other.name == @name
  end

  def eql?(other)
    other.name.eql? @name
  end

  def initialize(name, work_time)
    @name = name
    @work_time = work_time
  end
end

class Material
  attr_reader :id, :name, :note, :measure_type, :price, :base_width, :base_length

  def initialize(id, name, note, measure_type, price, base_w, base_l)
    @id = id
    @name = name
    @note = note
    @measure_type = measure_type
    @price = price
    @base_width = base_w
    @base_length = base_l
  end
end

class MaterialMeasureType
  attr_reader :name, :value

  private_class_method :new

  def self.from_value(val)
    case val
    when 0
      unit
    when 1
      length
    when 2
      area
    when 3
      weight
    else
      raise "Unknown value of measure type: #{val}"
    end
  end

  def self.unit
    new('unit', 0)
  end

  def self.length
    new('length', 1)
  end

  def self.area
    new('area', 2)
  end

  def self.weight
    new('weight', 3)
  end

  def ==(other)
    if other.is_a? MaterialMeasureType
      other.value == @value
    else
      other == @value
    end
  end

  def initialize(name, value)
    @name = name
    @value = value
  end
end

class ProductSummary
  attr_reader :id, :name, :description, :total_price

  def initialize(id, name, description, total_price)
    @id = id
    @name = name
    @description = description
    @total_price = total_price
  end
end

class ProductMaterial
  attr_reader :id, :name, :price

  def initialize(id, name, price)
    @id = id
    @name = name
    @price = price
  end

  def calculate_cost
    raise 'Method not implemented'
  end
end

class AreaProductMaterial < ProductMaterial
  attr_reader :width, :length, :base_width, :base_length

  def initialize(id, name, price, b_width, b_length, w, l)
    super(id, name, price)

    @base_width = b_width
    @base_length = b_length
    @width = w
    @length = l
  end

  def calculate_cost
    area = @width * @length
    unit_cost = @price / (@base_length * @base_width)

    area * unit_cost
  end
end

class UnitProductMaterial < ProductMaterial
  attr_reader :quantity

  def initialize(id, name, price, quantity)
    super(id, name, price)
    @quantity = quantity
  end

  def calculate_cost
    @price * @quantity
  end
end

class LengthProductMaterial < ProductMaterial
  attr_reader :quantity

  def initialize(id, name, price, quantity)
    super(id, name, price)
    @quantity = quantity
  end

  def calculate_cost
    @price * (@quantity / 100)
  end
end

class Product
  attr_reader :id, :name, :description, :minutes_needed, :profit, :materials

  def initialize(id, name, description, minutes_needed, profit, materials)
    @id = id
    @name = name
    @description = description
    @minutes_needed = minutes_needed
    @profit = profit
    @materials = materials
  end

  def calculate_final_price(salary_info, monthly_costs)
    material_cost = calculate_material_cost
    labor_cost = calculate_labor_cost(salary_info, monthly_costs)

    labor_cost + material_cost + calculate_profit_wage(salary_info, monthly_costs)
  end

  def calculate_material_cost
    material_sum = 0
    @materials.each do |m|
      material_sum += m.calculate_cost
    end
    material_sum
  end

  def calculate_labor_cost(salary_info, monthly_costs)
    wage = 0
    worked_minutes = 0
    fixed_cost_sum = monthly_costs.inject(0) { |sum, x| sum + x.value }

    salary_info.work_week.days.each do |day|
      worked_minutes += day.work_time
    end
    worked_minutes *= 4

    if worked_minutes != 0
      wage_per_minute = (salary_info.salary.value.to_f + fixed_cost_sum) / worked_minutes.to_f
      wage = wage_per_minute * @minutes_needed
    end

    wage
  end

  def calculate_profit_wage(salary_info, monthly_costs)
    material_cost = calculate_material_cost
    labor_cost = calculate_labor_cost(salary_info, monthly_costs)

    (material_cost + labor_cost) * (@profit / 100.0)
  end
end
