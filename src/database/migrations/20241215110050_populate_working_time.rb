Sequel.migration do
  up do
    run "INSERT INTO salary_info VALUES (1, 0, 0, 0, 0, 0, 0, 0, 0)"
  end

  down do
    run "DELETE FROM working_time WHERE 1 = 1"
  end
end
