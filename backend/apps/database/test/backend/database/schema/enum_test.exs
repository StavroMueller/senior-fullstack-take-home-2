defmodule Backend.Database.Schema.EnumTest do
  use Backend.Database.Test.DataCase, async: true

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry

  test "entry analysis statuses match the analysis_status database type" do
    assert Ecto.Enum.dump_values(Entry, :analysis_status) == database_values("analysis_status")
  end

  test "correction categories match the correction_category database type" do
    assert Ecto.Enum.dump_values(Correction, :category) == database_values("correction_category")
  end

  defp database_values(type_name) do
    %{rows: [[values]]} = Repo.query!("SELECT enum_range(NULL::#{type_name})::text[]")
    values
  end
end
