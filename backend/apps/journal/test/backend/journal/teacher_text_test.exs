defmodule Backend.Journal.TeacherTextTest do
  use ExUnit.Case, async: true

  alias Backend.Journal.TeacherText

  test "trims a usable scene" do
    assert TeacherText.usable({:ok, "  Bienvenue à Lyon.\n"}) == {:ok, "Bienvenue à Lyon."}
  end

  test "rejects blank text" do
    assert TeacherText.usable({:ok, "   "}) == :error
  end

  test "accepts text at the longest length and rejects one character more" do
    assert TeacherText.usable({:ok, String.duplicate("a", 600)}) ==
             {:ok, String.duplicate("a", 600)}

    assert TeacherText.usable({:ok, String.duplicate("a", 601)}) == :error
  end

  test "rejects a provider failure" do
    assert TeacherText.usable({:error, :provider_unavailable}) == :error
  end
end
