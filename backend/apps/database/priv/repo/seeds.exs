Backend.Database.Repo.transaction(fn ->
  Backend.Database.Commands.LoadExampleJourneys.execute(DateTime.utc_now(:second))
end)
