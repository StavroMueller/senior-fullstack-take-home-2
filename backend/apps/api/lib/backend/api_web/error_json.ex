defmodule Backend.ApiWeb.ErrorJSON do
  @moduledoc "Renders an HTTP error as JSON with the status text."

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
