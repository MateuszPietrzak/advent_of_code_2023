defmodule AdventOfCode2023.Day4.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day4.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end
end

defmodule AdventOfCode2023.Day4.Part1 do
  import AdventOfCode2023.Day4.Utility

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(fn [_, data] -> String.split(data, "| ") end)
    |> Enum.map(fn [a, b] ->
      [String.split(a, " ", trim: true), String.split(b, " ", trim: true)]
    end)
    |> Enum.map(fn [a, b] ->
      [Enum.map(a, &String.to_integer/1), Enum.map(b, &String.to_integer/1)]
    end)
    |> Enum.map(fn [a, b] -> Enum.count(a, fn x -> x in b end) end)
    |> Enum.map(fn x -> if x == 0, do: 0, else: Integer.pow(2, x - 1) end)
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day4.Part2 do
  import AdventOfCode2023.Day4.Utility

  def change_first_n([], _, _), do: []

  def change_first_n(list, 0, _), do: list

  def change_first_n(list, remaining, add_amount) do
    {amount, matching} = hd(list)
    [{amount + add_amount, matching} | change_first_n(tl(list), remaining - 1, add_amount)]
  end

  def get_score([], acc), do: acc

  def get_score(list, acc) do
    {amount, matching} = hd(list)

    new_tail = change_first_n(tl(list), matching, amount)

    get_score(new_tail, acc + amount)
  end

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(fn [_, data] -> String.split(data, "| ") end)
    |> Enum.map(fn [a, b] ->
      [String.split(a, " ", trim: true), String.split(b, " ", trim: true)]
    end)
    |> Enum.map(fn [a, b] ->
      [Enum.map(a, &String.to_integer/1), Enum.map(b, &String.to_integer/1)]
    end)
    |> Enum.map(fn [a, b] -> Enum.count(a, fn x -> x in b end) end)
    |> Enum.map(fn matching -> {1, matching} end)
    |> get_score(0)
  end
end
