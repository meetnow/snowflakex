
# Created by Patrick Schneider on 15.02.2017.
# Copyright (c) 2016 MeetNow! GmbH

defmodule Snowflakex.ClockError do
  @moduledoc """
  The snowflake could not be obtained due to the system clock moving backwards.
  """
  defexception [:message, :remaining]
end
