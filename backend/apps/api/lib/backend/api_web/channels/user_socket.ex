defmodule Backend.ApiWeb.UserSocket do
  @moduledoc "The browser's socket. There are no accounts, so every connection is accepted."

  use Phoenix.Socket

  channel "entry:*", Backend.ApiWeb.EntryChannel

  @impl true
  def connect(_params, socket, _connect_info), do: {:ok, socket}

  @impl true
  def id(_socket), do: nil
end
