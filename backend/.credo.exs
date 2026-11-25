%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["apps/*/lib/", "apps/*/test/", "apps/*/priv/", "config/", "credo_checks/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      requires: ["credo_checks/*.ex"],
      strict: true,
      color: true,
      checks: %{
        extra: [
          {Backend.CredoChecks.BooleanOperatorDefault, []},
          {Backend.CredoChecks.PipeIntoCase, []},
          {Backend.CredoChecks.CatchAllRescue, []},
          {Backend.CredoChecks.CommentRules, []},
          {Backend.CredoChecks.RepoInResolver, []},
          {Backend.CredoChecks.SingleLetterName, []},
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Design.TagTODO, [exit_status: 2]},
          {Credo.Check.Design.TagFIXME, []}
        ]
      }
    }
  ]
}
