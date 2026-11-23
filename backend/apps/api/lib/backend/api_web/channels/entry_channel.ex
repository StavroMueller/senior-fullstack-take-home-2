defmodule Backend.ApiWeb.EntryChannel do
  @moduledoc "Tells the browser when one entry's analysis ends."

  use Phoenix.Channel

  alias Backend.Database.Schema.Entry
  alias Backend.Journal

  @impl true
  def join("entry:" <> raw_entry_id, _params, socket) do
    with {entry_id, ""} <- Integer.parse(raw_entry_id),
         :ok <- Journal.subscribe_to_analysis(entry_id),
         %Entry{} = entry <- Journal.get_entry(entry_id) do
      {:ok, %{analysis_status: entry.analysis_status}, socket}
    else
      _no_such_entry -> {:error, %{reason: "not_found"}}
    end
  end

  @impl true
  def handle_info({:analysis_ended, _entry_id, :analyzed}, socket) do
    push(socket, "analysis_finished", %{})
    {:noreply, socket}
  end

  def handle_info({:analysis_ended, _entry_id, :analysis_failed}, socket) do
    push(socket, "analysis_failed", %{})
    {:noreply, socket}
  end
end
