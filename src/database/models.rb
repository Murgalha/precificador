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
    @days.filter { |x| x == :sunday }.first
  end

  def monday
    @days.filter { |x| x == :monday }.first
  end

  def tuesday
    @days.filter { |x| x == :tuesday }.first
  end

  def wednesday
    @days.filter { |x| x == :wednesday }.first
  end

  def thursday
    @days.filter { |x| x == :thursday }.first
  end

  def friday
    @days.filter { |x| x == :friday }.first
  end

  def saturday
    @days.filter { |x| x == :saturday }.first
  end
end

class WorkDay
  attr_reader :name, :work_time
  private_class_method :new

  def self.sunday(wk)
    return self.new(:sunday, wk)
  end

  def self.monday(wk)
    return self.new(:monday, wk)
  end

  def self.tuesday(wk)
    return self.new(:tuesday, wk)
  end

  def self.wednesday(wk)
    return self.new(:wednesday, wk)
  end

  def self.thursday(wk)
    return self.new(:thursday, wk)
  end

  def self.friday(wk)
    return self.new(:friday, wk)
  end

  def self.saturday(wk)
    return self.new(:saturday, wk)
  end

  def ==(other)
    puts "Comparison: #{other.name.eql? @name}"
    return other.name == @name
  end

  def eql?(other)
    puts "Comparison 2: #{other.name.eql? @name}"
    return other.name.eql? @name
  end


  def initialize(name, work_time)
    @name = name
    @work_time = work_time
  end
end

class Material
  attr_reader :id, :name, :note, :measure_type, :price, :base_width, :base_length

  def initialize(id, name, note, mt, price, base_w, base_l)
    @id = id
    @name = name
    @note = note
    @measure_type = mt
    @price = price
    @base_width = base_w
    @base_length = base_l
  end
end

class MaterialMeasureType
  attr_reader :name, :value
  private_class_method :new

  def self.from_value(v)
    if v == 0
      return self.unit
    elsif v == 1
      return self.length
    elsif v == 2
      return self.area
    elsif v == 3
      return self.weight
    else
      raise "Unknown value of measure type: #{v}"
    end
  end

  def self.unit
    self.new('unit', 0)
  end

  def self.length
    self.new('length', 1)
  end

  def self.area
    self.new('area', 2)
  end

  def self.weight
    self.new('weight', 3)
  end

  def ==(other)
    if other.is_a? MaterialMeasureType
      return other.value == @value
    else
      return other == @value
    end
  end

  def initialize(name, value)
    @name = name
    @value = value
  end
end
