# Wayword

Wayword is a language journal set on a trail across France. You write a few sentences at each
stop, in French, and get corrections on what you wrote. The assignment this answers is in
`ASSIGNMENT.md`.

## Run it

You need Docker.

```bash
docker compose up --build
```

Open http://localhost:5173. The GraphQL API answers at http://localhost:4000/api/graphql, and
Postgres listens on port 55433. The map loads its tiles from OpenFreeMap, so it needs internet.

## Test it

```bash
docker compose run --rm -e MIX_ENV=test backend mix test
docker compose run --rm frontend npm test
cd e2e && npm ci && npx playwright install chromium && npx playwright test
```

The Playwright spec runs against the stack that `docker compose up` started.

## How it is built

- `backend/`: an Elixir umbrella with four apps. `database` holds the repo, schemas and
  migrations; `journal` holds entries, corrections and journeys; `graphql` holds the Absinthe
  schema; `api` holds Phoenix, the GraphQL endpoint and the Oban queue.
- `frontend/`: React Router 7 as a single-page app, with Apollo Client, MUI and MapLibre GL JS.
- `e2e/`: the Playwright spec.

The product and design decisions, with the reason for each, are in `PRODUCT.md` and `DESIGN.md`.
