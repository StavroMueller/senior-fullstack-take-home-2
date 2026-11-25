# What Julien ruled against the agent's work

Every time Julien overturned something the agent wrote, the ruling goes here with the code before
and after. The agent reads this file before writing code and adds a section the same day a new
ruling lands. The rule itself also goes into `CLAUDE.md`, and this file keeps the example.

## 2026-11-24

### A changeset lives in its schema

The agent kept the entry's `cast` and validations in the command that wrote the row, because the
audit checklist said "Changesets belong to the command that writes the row." Julien ruled that a
changeset is the one piece of logic a schema holds, since it is tied to the schema.

Rejected, in `Backend.Journal.Commands.SubmitEntry`:

```elixir
defp entry_changeset(journey, body, route_position) do
  %Entry{analysis_status: :analyzing, journey_id: journey.id}
  |> cast(Map.put(route_position, :body, trim_and_compose(body)), [:body, :point_of_interest_index, :encounter_id])
  |> validate_required([:body])
  |> validate_length(:body, max: @longest_body)
end
```

Write instead, in `Backend.Database.Schema.Entry`, and call it from the command:

```elixir
def submission_changeset(%__MODULE__{} = entry, attributes) do
  entry
  |> cast(attributes, [:body, :point_of_interest_index, :encounter_id])
  |> update_change(:body, &trim_and_compose/1)
  |> validate_required([:body])
  |> validate_length(:body, max: @longest_body)
end
```

### Every changeset, even a bare status change

The agent moved the validating changeset into the schema but left `Ecto.Changeset.change/2` calls
in the commands, on the grounds that they set known values. Julien asked for the same treatment
everywhere.

Rejected, in `Backend.Journal.Commands.FailAnalysis`:

```elixir
entry |> Ecto.Changeset.change(analysis_status: :analysis_failed) |> Repo.update()
```

Write instead, with the changeset on `Entry` and named for the write:

```elixir
entry |> Entry.analysis_failed_changeset() |> Repo.update()
```

No command calls `Ecto.Changeset` to build a changeset.

### Bind the Multi, then case on the transaction

`CLAUDE.md` had allowed a `Multi` chain to end in `Repo.transaction() |> case do`, and the agent
followed it. Julien ruled that the bound form is the only accepted one.

Rejected:

```elixir
Multi.new()
|> Multi.insert(:entry, entry_changeset)
|> Repo.transaction()
|> case do
  {:ok, %{entry: entry}} -> {:ok, entry}
  {:error, :entry, changeset, _changes} -> {:error, changeset}
end
```

Write instead:

```elixir
multi =
  Multi.new()
  |> Multi.insert(:entry, entry_changeset)

case Repo.transaction(multi) do
  {:ok, %{entry: entry}} -> {:ok, entry}
  {:error, :entry, changeset, _changes} -> {:error, changeset}
end
```

The Credo check `Backend.CredoChecks.PipeIntoCase` fails on any `|> case`. The rule is also in the
starter kit, on the branch `multi-and-changeset-rules`.

### No Dataloader for one person's journal

The agent kept Dataloader because the stack ruling listed it. Julien judged it overkill: batching
saved a few queries on a list of three to five journeys. The journal queries now preload what the
GraphQL fields read, and each association declares its order once with `preload_order` on the
schema.

### No helper module for a one-line list

To avoid writing a preload list twice, the agent added `Backend.Journal.LoadedAssociations`, one
of whose two functions had a single caller. Julien questioned the abstraction. `CLAUDE.md` already
says three similar lines beat a clever abstraction.

Rejected:

```elixir
|> Repo.preload(LoadedAssociations.journey())
```

Write instead, in each query:

```elixir
|> Repo.preload([:encounters, entries: [:corrections, :encounter]])
```

### Sibling queries read the same way

`ListJourneys` preloaded with the `Ecto.Query.preload/3` macro, which needs a pin, while
`GetJourney` and `GetEntry` used `Repo.preload/2`. Julien asked why one was pinned and the others
were not. Siblings use one form, so all three now end in `Repo.preload/2`.

Rejected:

```elixir
Journey
|> order_by(desc: :inserted_at, desc: :id)
|> preload(^LoadedAssociations.journey())
|> Repo.all()
```

Write instead:

```elixir
Journey
|> order_by(desc: :inserted_at, desc: :id)
|> Repo.all()
|> Repo.preload([:encounters, entries: [:corrections, :encounter]])
```

### Example journeys load at every boot

The agent left seeding as a manual command. Julien asked for the seeds to run on server start, and
chose to load them on every boot over loading them only into an empty journal, accepting that a
restart deletes what was written.

### One open pull request takes the related work

The agent started the changeset change on a new branch from `main`. Julien said to put it all in
the open pull request, #23.

### Act on the repository named

Asked to resolve conflicts, the agent began by checking the pull requests of both Wayword and the
starter kit. Julien stopped the call and named the challenge pull request. Work on the repository
the request names.
