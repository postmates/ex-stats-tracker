defmodule ExStatsTrackerTest do
  use ExUnit.Case

  describe "overidden options" do
    test "override host through options" do
      host = :some_host
      options = [host: host]

      {:ok, _pid} = ExStatsTracker.start_link(options)

      assert state().host === host
    end

    test "override port through options" do
      port = :some_port
      options = [port: port]

      {:ok, _pid} = ExStatsTracker.start_link(options)

      assert state().port === port
    end

    test "override prefix through options" do
      prefix = :some_prefix
      options = [prefix: prefix]

      {:ok, _pid} = ExStatsTracker.start_link(options)

      assert state().prefix === prefix
    end

    test "override chunk_size through options" do
      chunk_size = :chunk_size
      options = [chunk_size: chunk_size]

      {:ok, _pid} = ExStatsTracker.start_link(options)

      assert state().chunk_size === chunk_size
    end
  end

  describe "default options" do
    setup do
      {:ok, pid} = ExStatsTracker.start_link
      {:ok, pid: pid}
    end

    test "counter" do
      :ok = 99 |> ExStatsTracker.counter("items")
      assert sent() == [{:counter, "items", 99}]
    end

    test "increment" do
      :ok = ExStatsTracker.increment("items")
      assert sent() == [{:counter, "items", 1}]
    end

    test "decrement" do
      :ok = ExStatsTracker.decrement("items")
      assert sent() == [{:counter, "items", -1}]
    end

    test "gauge" do
      :ok = 99 |> ExStatsTracker.gauge("items")
      assert sent() == [{:gauge, "items", 99}]
    end

    test "timing" do
      :ok = 99 |> ExStatsTracker.timing("items")
      assert sent() == [{:timer, "items", 99}]
    end

    test "histogram" do
      :ok = 99 |> ExStatsTracker.histogram("items")
      assert sent() == [{:histogram, "items", 99}]
    end

    test "meter" do
      :ok = 99 |> ExStatsTracker.meter("items")
      assert sent() == [{:meter, "items", 99}]
    end

    test "flush" do
      assert :ok == ExStatsTracker.flush
    end
  end

  defp state(name \\ ExStatsTracker), do: :sys.get_state(name)

  defp sent(name \\ExStatsTracker), do: state(name).msgs
end
