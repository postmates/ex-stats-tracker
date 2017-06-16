defmodule ExStatsTracker do
  use GenServer

  # config options:
  #   host (default: {127,0,0,1}: Host address of Statsd
  #   port (default: 8125): Port address of Statsd
  #   prefix (default: nil): Prefix all messages with given "prefix."
  #   flush_interval (default: 15000): how often to push stats
  #   chunk_size (default: 25): Maximum number of messages to send to statsd in one packet

  @default_host {127, 0, 0, 1}
  @default_port 8125
  @default_prefix nil
  @default_flush_interval 15000
  @default_chunk_size 25

  def init(opts \\ []) do
    state = %{
      msgs: [],
      host: Application.get_env(:ex_stats_tracker, :host,
        Keyword.get(opts, :host, @default_host)),
      port: Application.get_env(:ex_stats_tracker, :port,
        Keyword.get(opts, :port, @default_port)),
      chunk_size: Application.get_env(:ex_stats_tracker, :chunk_size,
        Keyword.get(opts, :chunk_size, @default_chunk_size)),
    }

    flush_interval = Application.get_env(:ex_stats_tracker, :flush_interval,
      Keyword.get(opts, :flush_interval, @default_flush_interval))

    # TODO(hayesgm): kill time_ref on death
    {:ok, _time_ref} = :timer.apply_interval(flush_interval, __MODULE__, :flush, [])

    {:ok, state}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def handle_cast(msg, state) do
    new_state = %{ state | msgs: [ msg | state.msgs ] }
    {:noreply, new_state}
  end

  def handle_call(:flush, _from, state) do

    # Spawn a new process
    spawn fn ->
      {:ok, socket} = :gen_udp.open(0)

      chunks = Enum.chunk(state.msgs, state.chunk_size, state.chunk_size, [])

      Enum.each(chunks, fn msgs ->
        :gen_udp.send(socket, state.host, state.port, msgs)
      end)
    end

    {:reply, :ok, %{state | msgs: []}}
  end

  def flush() do
    :ok = GenServer.call(__MODULE__, :flush)
  end

  defp command(type, key, val) do
    # TODO(hayesgm): Fail if key > 100 characters
    GenServer.cast(__MODULE__,
      {type, key, val}
      |> update_msg_with_prefix
      |> build_statsd_line
    )
  end

  defp update_msg_with_prefix(msg={type, key, value}) do
    prefix = Application.get_env(:ex_stats_tracker, :prefix, @default_prefix)
    case prefix do
      nil -> msg
      prefix -> {type, prefix <> "." <> key, value}
    end
  end

  # Public statsd commands
  def counter(val, key) when is_number(val) and is_binary(key) do
    command(:counter, key, val)
  end

  def increment(key) when is_binary(key) do
    counter(1, key)
  end

  def decrement(key) when is_binary(key) do
    counter(-1, key)
  end

  def gauge(val, key) when is_number(val) and is_binary(key) do
    command(:gauge, key, val)
  end

  def timing(val, key) when is_number(val) and is_binary(key) do
    command(:timer, key, val)
  end

  def histogram(val, key) when is_number(val) and is_binary(key) do
    command(:histogram, key, val)
  end

  def meter(val, key) when is_number(val) and is_binary(key) do
    command(:meter, key, val)
  end

  # Build pipe version of each command
  defp build_statsd_line({:counter, key, val}) do
    # TODO: sample rate
    "#{key}:#{val}|c\n"
  end

  defp build_statsd_line({:gauge, key, val}) do
    "#{key}:#{val}|g\n"
  end

  defp build_statsd_line({:timer, key, val}) do
    "#{key}:#{val}|ms\n"
  end

  defp build_statsd_line({:histogram, key, val}) do
    "#{key}:#{val}|h\n"
  end

  defp build_statsd_line({:meter, key, val}) do
    "#{key}:#{val}|m\n"
  end

end
