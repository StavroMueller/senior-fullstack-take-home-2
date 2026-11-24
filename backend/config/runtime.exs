import Config

openrouter_api_key = System.get_env("OPENROUTER_API_KEY", "")

if config_env() != :test and openrouter_api_key != "" do
  config :journal, :ai_provider, Backend.Journal.AiProvider.OpenRouter
  config :journal, Backend.Journal.AiProvider.OpenRouter, api_key: openrouter_api_key
end
