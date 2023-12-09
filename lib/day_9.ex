defmodule AdventOfCode2023.Day9.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day9.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def diff_pairwise([a, b]), do: [b - a]

  def diff_pairwise([a, b | tail]) do
    [b - a | diff_pairwise([b | tail])]
  end
end

defmodule AdventOfCode2023.Day9.Part1 do
  import AdventOfCode2023.Day9.Utility

  def get_extrapolated(list) do
    if Enum.all?(list, fn x -> x == 0 end) do
      List.last(list)
    else
      List.last(list) + get_extrapolated(diff_pairwise(list))
    end
  end

  def solve do
    get_file()
    |> Enum.map(&String.split/1)
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.map(&get_extrapolated/1)
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day9.Part2 do
  import AdventOfCode2023.Day9.Utility

  def get_extrapolated(list) do
    if Enum.all?(list, fn x -> x == 0 end) do
      List.first(list)
    else
      List.first(list) - get_extrapolated(diff_pairwise(list))
    end
  end

  def solve do
    get_file()
    |> Enum.map(&String.split/1)
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.map(&get_extrapolated/1)
    |> Enum.sum()
  end
end
