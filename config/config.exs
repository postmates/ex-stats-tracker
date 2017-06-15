use Mix.Config

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if Mix.env == :test do
  import_config "#{Mix.env}.exs"
end
