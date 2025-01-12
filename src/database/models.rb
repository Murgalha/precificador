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
  def initialize(week_hash)
    @days = {}
    week_hash.each do |key, value|
      @days[key] = WorkDay.new(key, value)
    end
  end

  def days
    day_list = [
      :sunday,
      :monday,
      :tuesday,
      :wednesday,
      :thursday,
      :friday,
      :saturday
    ]

    day_list.map { |d| @days[d] }
  end

  def sunday
    @days[:sunday]
  end

  def monday
    @days[:monday]
  end

  def tuesday
    @days[:tuesday]
  end

  def wednesday
    @days[:wednesday]
  end

  def thursday
    @days[:thursday]
  end

  def friday
    @days[:friday]
  end

  def saturday
    @days[:saturday]
  end
end

class WorkDay
  attr_reader :name, :work_time

  def initialize(name, work_time)
    @name = name
    @work_time = work_time
  end
end
