
# Created by Patrick Schneider on 05.12.2016.
# Copyright (c) 2016,2020 MeetNow! GmbH

defmodule Snowflakex.Worker do
  @moduledoc """
  Worker module for Snowflakex.

  Implements a GenServer.

  Do not use this directly, call `Snowflakex.new/0` or `Snowflakex.new!/0`
  instead.
  """
  use GenServer
  require Logger

  @max_machine_id 1023
  @rollover_seq 4096
  @snx_epoch 1480927901749

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def start_link(machine_id)
      when is_integer(machine_id) and machine_id >= 0 and machine_id <= @max_machine_id do
    GenServer.start_link(__MODULE__, machine_id, name: __MODULE__)
  end

  @impl true
  def init(machine_id) do
    {:ok, {machine_id, get_ts(), 0}}
  end

  @impl true
  def handle_call(:new, _from, {machine_id, last_ts, seq}) do
    {ts, seq} = case get_ts() do
      ^last_ts ->
        case seq + 1 do
          @rollover_seq -> {busy_wait_timechange(last_ts), 0}
          next_seq -> {last_ts, next_seq}
        end
      ts ->
        {ts, 0}
    end
    if ts < last_ts do
      Logger.error "Snowflakex: Clock is moving backwards. Rejecting requests until #{last_ts}."
      remaining = last_ts - ts
      {:reply, %Snowflakex.ClockError{message: "Clock moved backwards. Refusing to generate an ID for #{remaining} milliseconds.", remaining: remaining}, {machine_id, last_ts, seq}}
    else
      <<new_id :: integer-size(64)>> = <<
        0 :: size(1),
        ts :: unsigned-integer-size(41),
        machine_id :: unsigned-integer-size(10),
        seq :: unsigned-integer-size(12)
      >>
      {:reply, new_id, {machine_id, ts, seq}}
    end
  end

  defp get_ts() do
    :erlang.system_time(:millisecond) - @snx_epoch
  end

  defp busy_wait_timechange(last_ts) do
    case get_ts() do
      ^last_ts -> busy_wait_timechange(last_ts)
      ts -> ts
    end
  end
end
