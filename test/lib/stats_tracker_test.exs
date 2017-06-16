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
      :ok = 99 |> ExStatsTracker.counter("counter")
      assert sent() == ["test_prefix.counter:99|c\n"]
    end

    test "increment" do
      :ok = ExStatsTracker.increment("increment")
      assert sent() == ["test_prefix.increment:1|c\n"]
    end

    test "decrement" do
      :ok = ExStatsTracker.decrement("decrement")
      assert sent() == ["test_prefix.decrement:-1|c\n"]
    end

    test "gauge" do
      :ok = 99 |> ExStatsTracker.gauge("gauge")
      assert sent() == ["test_prefix.gauge:99|g\n"]
    end

    test "timing" do
      :ok = 99 |> ExStatsTracker.timing("timing")
      assert sent() == ["test_prefix.timing:99|ms\n"]
    end

    test "histogram" do
      :ok = 99 |> ExStatsTracker.histogram("histogram")
      assert sent() == ["test_prefix.histogram:99|h\n"]
    end

    test "meter" do
      :ok = 99 |> ExStatsTracker.meter("meter")
      assert sent() == ["test_prefix.meter:99|m\n"]
    end

    test "flush" do
      assert :ok == ExStatsTracker.flush
    end
  end

  defp state(name \\ ExStatsTracker), do: :sys.get_state(name)

  defp sent(name \\ExStatsTracker), do: state(name).msgs
end
