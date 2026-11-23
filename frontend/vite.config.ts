import { reactRouter } from "@react-router/dev/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [reactRouter()],
  resolve: { tsconfigPaths: true },
  ssr: { noExternal: ["@apollo/client"] },
  server: { host: "0.0.0.0", port: 5173 },
});
