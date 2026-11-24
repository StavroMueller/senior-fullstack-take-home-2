import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const repositoryRoot = fileURLToPath(new URL("..", import.meta.url));

const truncateEveryTableButMigrations = `
DO $$ BEGIN
  EXECUTE (
    SELECT 'TRUNCATE ' || string_agg(format('%I', tablename), ', ') || ' RESTART IDENTITY CASCADE'
    FROM pg_tables
    WHERE schemaname = 'public' AND tablename <> 'schema_migrations'
  );
END $$;
`;

export default function resetDatabase() {
  execFileSync(
    "docker",
    [
      "compose",
      "exec",
      "-T",
      "database",
      "psql",
      "--username=postgres",
      "--dbname=wayword_dev",
      "--set=ON_ERROR_STOP=1",
      "--command",
      truncateEveryTableButMigrations,
    ],
    { cwd: repositoryRoot, stdio: "inherit" },
  );
}
