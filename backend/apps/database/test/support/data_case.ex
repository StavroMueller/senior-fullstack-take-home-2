defmodule Backend.Database.Test.DataCase do
  @moduledoc "A test case with the repo checked out in the SQL sandbox."

  use ExUnit.CaseTemplate

  alias Backend.Database.Repo
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Backend.Database.Repo
    end
  end

  setup tags do
    check_out_repo(tags)
  end

  def check_out_repo(tags) do
    owner = Sandbox.start_owner!(Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(owner) end)
    :ok
  end
end
