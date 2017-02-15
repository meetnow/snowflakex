# Snowflakex

Snowflakex (pronounced "snowflakes") is a service for generating unique ID
numbers at high scale with some simple guarantees.

It is directly modeled after Twitter's Snowflake specification.

## Requirements

### Performance

* Minimum 10k IDs per second per node
* Response rate <= 2ms

### Uncoordinated

For high availability within and across server application instances, nodes
generating IDs should not have to coordinate with each other.

### (Roughly) Time Ordered

We can guarantee, that the ID numbers will be k-sorted (references:
http://portal.acm.org/citation.cfm?id=70413.70419 and http://portal.acm.org/citation.cfm?id=110778.110783)
within a reasonable bound (we're promising 1s, but shooting for 10's of ms).

### Directly Sortable

The IDs should be sortable without loading the full objects that they represent.
This sorting should be the above ordering.

### Compact

There are many otherwise reasonable solutions to this problem that require
128-bit numbers. To accomodate most systems, we keep our IDs under 64 bits.

### Highly Available

The ID generation scheme should be at least as available as the related services.

## Solution

* The ID numbers are 64-bit integers composed of:
    * Unused sign bit kept at 0
    * Timestamp - 41 bits (millisecond precision with a custom epoch gives us 69 years)
    * Configured machine id - 10 bits - gives us up to 1024 machines
    * Sequence number - 12 bits - rolls over every 4096 per machine (with protection to avoid rollover in the same ms)

## System Clock Dependency

You should use NTP to keep your system clock accurate. Snowflakex protects from
non-monotonic clocks, i.e. clocks that run backwards. If your clock is running
fast and NTP tells it to repeat a few milliseconds, snowflakex will refuse to
generate ids until a time that is after the last time we generated an id. Even
better, run in a mode where ntp won't move the clock backwards. See
http://wiki.dovecot.org/TimeMovedBackwards#Time_synchronization
for tips on how to do this.

## Installation

The package can be installed as:

  1. Add `snowflakex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:snowflakex, "~> 1.1.0"}]
    end
    ```

  2. Ensure `snowflakex` is started before your application:

    ```elixir
    def application do
      [applications: [:snowflakex]]
    end
    ```

  3. Configure the machine id through your `config.exs`:

    ```elixir
    config :snowflakex, machine_id: 123
    ```

## Usage

The library only offers two simple calls:

```elixir
Snowflakex.new()
```

This call either returns `{:ok, snowflake}` or `{:error, errormessage}` where
the latter only occurs when the system clock moved backwards.

```elixir
Snowflakex.new!()
```

This call will either return the snowflake directly or raise a Snowflakex.ClockError
with the error message and remaining time.
