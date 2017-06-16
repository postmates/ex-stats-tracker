# ex-stats-tracker
Statsd Client for Elixir

## Installation

  1. Add `ex-stats-tracker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:ex_stats_tracker, "~> 0.1.0"}]
end
```

  2. Ensure `ex_stats_tracker` is started before your application:

```elixir
def application do
  [extra_applications: [:ex_stats_tracker]]
end
```

## Configuration

Configure ex_stats_tracker in config:

```elixir
use Mix.Config

config :ex_stats_tracker,
       host: "your.statsd.host.com",
       port: 1234,
       prefix: "your_prefix"
       flush_interval: 10000
       chunk_size: 20
```

The defaults are:

* host: 127.0.0.1
* port: 8125
* prefix: nil
* flush_interval: 15000
* chunk_size: 25

## Usage

```elixir
iex> ExStatsTracker.counter(your_key, 1)
iex> ExStatsTracker.increment(your_key)
iex> ExStatsTracker.gauge(your_key)
iex> ExStatsTracker.timing(your_metric, 1)
iex> ExStatsTracker.histogram(your_metric, 1)
iex> ExStatsTracker.meter(your_metric, 1)
```
