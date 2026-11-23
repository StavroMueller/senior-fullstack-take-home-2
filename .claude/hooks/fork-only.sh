#!/bin/sh
input=$(cat)
case "$input" in
  *appliedcomputingtech*)
    echo "Blocked: nothing goes to the company repo appliedcomputingtech/senior-fullstack-take-home-2. Use the fork StavroMueller/senior-fullstack-take-home-2." >&2
    exit 2 ;;
esac
case "$input" in
  *"gh pr create"*)
    case "$input" in
      *"--repo StavroMueller/senior-fullstack-take-home-2"*) exit 0 ;;
      *)
        echo "Blocked: gh pr create needs --repo StavroMueller/senior-fullstack-take-home-2, so the pull request opens on the fork." >&2
        exit 2 ;;
    esac ;;
esac
case "$input" in
  *"git push upstream"*|*"push upstream "*)
    echo "Blocked: never push to upstream, the company repo. Push to origin, the fork." >&2
    exit 2 ;;
esac
exit 0
