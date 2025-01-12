require 'sequel'
require_relative 'models'

class DatabaseHandle
  def initialize(connection_string)
    @connection_string = connection_string
    @db = Sequel.sqlite(@connection_string)
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
    week_hash = {
      :sunday => row[:sunday],
      :monday => row[:monday],
      :tuesday => row[:tuesday],
      :wednesday => row[:wednesday],
      :thursday => row[:thursday],
      :friday => row[:friday],
      :saturday => row[:saturday],
    }

    return SalaryInfo.new(salary, WorkWeek.new(week_hash))
  end

  def update_salary_info(new_salary, week_hash)
    values = week_hash.clone
    values[:salary] = new_salary

    @db[:salary_info].update(values)
  end
end
