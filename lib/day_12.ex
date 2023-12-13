defmodule AdventOfCode2023.Day12.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day12.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def arrangement_count([], x) do
    if length(x) == 0, do: 1, else: 0
  end

  def arrangement_count(chars_list, []) do
    if Enum.all?(chars_list, fn x -> x == ?. or x == ?? end), do: 1, else: 0
  end

  def arrangement_count(chars_list = [head | tail], info = [info_head | info_tail]) do
    case head do
      ?. ->
        arrangement_count(tail, info)

      35 ->
        if check_drop(chars_list, info_head) do
          arrangement_count(Enum.drop(chars_list, info_head + 1), info_tail)
        else
          0
        end

      _ ->
        if check_drop(chars_list, info_head) do
          arrangement_count(Enum.drop(chars_list, info_head + 1), info_tail) +
            arrangement_count(tail, info)
        else
          arrangement_count(tail, info)
        end
    end
  end

  def check_drop([], 0), do: true

  def check_drop([head | _], 0) do
    head != 35
  end

  def check_drop([], _), do: false

  def check_drop([head | tail], to_drop) do
    if head == ?. do
      false
    else
      check_drop(tail, to_drop - 1)
    end
  end

  def calculate_score([chars, info]) do
    num_info =
      info
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    chars_list =
      chars
      |> String.to_charlist()

    arrangement_count(chars_list, num_info)
  end
end

defmodule AdventOfCode2023.Day12.Part1 do
  import AdventOfCode2023.Day12.Utility

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(&calculate_score/1)
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day12.Part2 do
  import AdventOfCode2023.Day12.Utility

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [a, b] ->
      [
        a <> "?" <> a <> "?" <> a <> "?" <> a <> "?" <> a,
        b <> "," <> b <> "," <> b <> "," <> b <> "," <> b
      ]
    end)
    |> Task.async_stream(&(calculate_score(&1) |> IO.inspect()),
      timeout: :infinity,
      max_concurrency: System.schedulers_online()
    )
    |> Enum.to_list()
    |> Enum.map(fn {:ok, val} -> val end)
    |> Enum.sum()
  end
end
