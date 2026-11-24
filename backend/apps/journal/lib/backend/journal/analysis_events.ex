defmodule Backend.Journal.AnalysisEvents do
  @moduledoc "Announces the end of an entry's analysis to whoever subscribed to that entry."

  @pubsub Backend.Journal.PubSub

  @doc "Subscribes the calling process to the end of one entry's analysis."
  def subscribe(entry_id), do: Phoenix.PubSub.subscribe(@pubsub, topic(entry_id))

  @doc "Sends `{:analysis_ended, analysis_status}` to every subscriber of the entry."
  def broadcast_analysis_ended(entry_id, analysis_status) do
    Phoenix.PubSub.broadcast(
      @pubsub,
      topic(entry_id),
      {:analysis_ended, analysis_status}
    )
  end

  defp topic(entry_id), do: "analysis:#{entry_id}"
end
