defmodule ExercismCliEx do
  @moduledoc """
  Documentation for `ExercismCliEx`.
  """

  @doc """
  fetch list of id's from the given page of results.

  ## Examples

      iex> ExercismCliEx.fetch("123")
      []

  """

  def get_token() do
    {body, _} = System.cmd("exercism", ["configure"], stderr_to_stdout: true)

    body
    |> String.split("\n")
    |> Enum.find(fn x -> String.starts_with?(x, "Token") end)
    |> String.split(")")
    |> Enum.at(1)
    |> String.trim()
  end

  def fetch(token, page \\ 1) do
    %HTTPoison.Response{body: body, status_code: 200} =
      HTTPoison.get!(
        "https://exercism.org/api/v2/mentoring/discussions?status=awaiting_student&criteria=&page=#{page}",
        Authorization: "Token #{token}"
      )

    Poison.Parser.parse!(body)
    |> Map.get("results")
    |> Enum.map(&Map.get(&1, "uuid"))
  end

  def nudge(token, uuid) do
    msg = """
    It's been a while!

    How is this exercise going? Are you planning on making more changes?

    If you are ready to move on, you can free up your mentoring slot for Elixir (you have upto 4 per track) by clicking
    "End discussion".

    If you are still working on this, that is great, too!

    If you have any questions or what any help or tips, just let me know!
    """

    body = Poison.encode!(%{content: msg})

    HTTPoison.post!("https://exercism.org/api/v2/mentoring/discussions/#{uuid}/posts", body,
      Authorization: "Token #{token}",
      "Content-Type": "application/json"
    )
  end

  def fetch_and_nudge(token, page \\ 1) do
    fetch(token, page)
    |> Enum.map(&nudge(token, &1))
  end
end
