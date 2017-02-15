
# Created by Patrick Schneider on 05.12.2016.
# Copyright (c) 2016 MeetNow! GmbH

defmodule Snowflakex do
  @moduledoc """
  Main module of Snowflakex.
  """
  use Application
  import Supervisor.Spec

  @doc """
  Callback implementation for `Application.start/2`.
  """
  def start(_type, _args) do
    machine_id = Application.get_env(:snowflakex, :machine_id)
    Supervisor.start_link([ worker(Snowflakex.Worker, [machine_id]) ], strategy: :one_for_one)
  end

  @doc """
  Obtain a new snowflake.

  Returns either `{:ok, snowflake}` or `{:error, errormessage}`.
  """
  def new() do
    case GenServer.call(Snowflakex.Worker, :new) do
      %Snowflakex.ClockError{message: message} -> {:error, message}
      snowflake -> {:ok, snowflake}
    end
  end

  @doc """
  Obtain a new snowflake.

  Raises `Snowflakex.ClockError` on error.
  """
  def new!() do
    case GenServer.call(Snowflakex.Worker, :new) do
      %Snowflakex.ClockError{} = error -> raise error
      snowflake -> snowflake
    end
  end
end
