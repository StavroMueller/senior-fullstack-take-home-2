defmodule Backend.ApiWeb.Test.FailingAiProvider do
  @moduledoc "An AI provider that always fails, for testing the failed analysis path."

  @behaviour Backend.Journal.AiProvider

  @impl true
  def correct_entry(_body, _language, _level), do: {:error, :provider_unavailable}
end
