import { ApolloClient, HttpLink, InMemoryCache } from "@apollo/client";

export const apolloClient = new ApolloClient({
  link: new HttpLink({
    uri: import.meta.env.VITE_API_URL ?? "http://localhost:4000/api/graphql",
  }),
  cache: new InMemoryCache(),
});
