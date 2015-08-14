Sequel.migration do
  up do
    create_table(:activity_streams) do
      primary_key :id

    end
  end
end