defmodule AdventOfCode2023.Day8.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day8.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end
end

defmodule AdventOfCode2023.Day8.Part1 do
  import AdventOfCode2023.Day8.Utility

  def count_steps(map, key, [], directions_copy),
    do: count_steps(map, key, directions_copy, directions_copy)

  def count_steps(map, key, [direction | tail], directions_copy) do
    next_key = map[key][direction]

    [_, _, a] = String.to_charlist(next_key)

    if a == ?Z do
      1
    else
      1 + count_steps(map, next_key, tail, directions_copy)
    end
  end

  def solve do
    [dir | map_string] = get_file()

    directions = dir |> String.to_charlist() |> Enum.map(&if &1 == ?L, do: :left, else: :right)

    map =
      map_string
      |> Enum.map(&String.split(&1, [" = (", ", ", ")"], trim: true))
      |> Enum.reduce(%{}, fn [key, left, right], acc ->
        Map.put(acc, key, left: left, right: right)
      end)

    map
    |> Enum.map(fn {key, _} ->
      with [_, _, a] <- String.to_charlist(key) do
        if a == ?A do
          count_steps(map, key, directions, directions)
        else
          0
        end
      end
    end)
    |> Enum.reduce(1, fn x, acc ->
      if x == 0 do
        acc
      else
        div(acc * x, Integer.gcd(acc, x))
      end
    end)
  end
end
