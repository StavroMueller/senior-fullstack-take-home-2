defmodule Backend.Journal.AiProvider do
  @moduledoc "The contract every AI provider meets: entry text in, the provider's corrections response out."

  @callback correct_entry(body :: String.t(), language :: String.t(), level :: String.t()) ::
              {:ok, map()} | {:error, term()}
end
