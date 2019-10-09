defmodule MFPB.Requests.Bin do
  use GenServer, restart: :temporary

  require Logger

  alias MFPB.Config
  alias MFPB.Requests.Request
  alias MFPB.Requests.Bin.Registry, as: BinRegistry

  def start_link(args) do
    bin_id = Keyword.fetch!(args, :bin_id)
    GenServer.start_link(__MODULE__, args, name: via_tuple(bin_id))
  end

  def get_all(bin_id) do
    via_tuple(bin_id)
    |> GenServer.call(:get_all)
  end

  def append(bin_id, %Request{} = request) do
    via_tuple(bin_id)
    |> GenServer.call({:append, request})
  end

  defp via_tuple(bin_id) do
    {:via, Registry, {BinRegistry, bin_id}}
  end

  def init(args) do
    bin_id = Keyword.fetch!(args, :bin_id)
    {:ok, %{bin_id: bin_id, requests: [], count: 0}, Config.bin_inactivity_timeout_ms()}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state.requests, state, Config.bin_inactivity_timeout_ms()}
  end

  def handle_call({:append, request}, _from, state) do
    if state.count >= Config.bin_max_requests() do
      Logger.info("Bin #{state.bin_id} exceeded max size, stopping it")
      Phoenix.PubSub.broadcast(MFPB.PubSub, "bins:#{state.bin_id}", :bin_size_exceeded)
      {:stop, :shutdown, {:error, :bin_size_exceeded}, state}
    else
      new_state = %{state | requests: [request | state.requests], count: state.count + 1}
      {:reply, :ok, new_state, Config.bin_inactivity_timeout_ms()}
    end
  end

  def handle_info(:timeout, state) do
    Logger.info("Bin #{state.bin_id} timed out, stopping it")
    Phoenix.PubSub.broadcast(MFPB.PubSub, "bins:#{state.bin_id}", :bin_timeout)
    {:stop, :shutdown, state}
  end
end
