defmodule Backend.ApiWeb.Test.FailingAiProvider do
  @moduledoc "An AI provider that always fails, for testing the failed analysis path."

  @behaviour Backend.Journal.AiProvider

  @impl true
  def describe_point_of_interest(_town, _language, _level), do: {:error, :provider_unavailable}

  @impl true
  def introduce_journey(_towns, _language, _level), do: {:error, :provider_unavailable}

  @impl true
  def correct_entry(_body, _language, _level), do: {:error, :provider_unavailable}
end
