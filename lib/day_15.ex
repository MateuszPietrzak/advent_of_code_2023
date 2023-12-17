defmodule AdventOfCode2023.Day15.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day15.in")

    IO.read(file, :eof)
    |> String.split([",", "\n"], trim: true)
  end

  def hash([], score), do: score

  def hash([head | tail], score) do
    if head == ?\n do
      hash(tail, score)
    else
      hash(tail, rem((score + head) * 17, 256))
    end
  end
end

defmodule AdventOfCode2023.Day15.Part1 do
  import AdventOfCode2023.Day15.Utility

  def solve do
    get_file()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&hash(&1, 0))
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day15.Part2 do
  import AdventOfCode2023.Day15.Utility

  def process_line({str, hash, :dash}, acc) do
    cur_box = Enum.at(acc, hash)
    index = Enum.find_index(cur_box, fn {s, _} -> s == str end)

    if index != nil do
      List.replace_at(acc, hash, List.delete_at(cur_box, index))
    else
      acc
    end
  end

  def process_line({str, hash, {:equals, value}}, acc) do
    cur_box = Enum.at(acc, hash)
    index = Enum.find_index(cur_box, fn {s, _} -> s == str end)

    if index != nil do
      List.replace_at(acc, hash, List.replace_at(cur_box, index, {str, value}))
    else
      new_box = [{str, value} | cur_box]
      List.replace_at(acc, hash, new_box)
    end
  end

  def solve do
    get_file()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(fn x ->
      with y <- Enum.take_while(x, &(&1 != ?= and &1 != ?-)) do
        {y, hash(y, 0),
         if(Enum.any?(x, &(&1 == ?=)),
           do:
             {:equals,
              Enum.drop_while(x, fn char -> char < ?0 or char > ?9 end)
              |> List.to_string()
              |> String.to_integer()},
           else: :dash
         )}
      end
    end)
    |> Enum.reduce(List.duplicate([], 256), &process_line/2)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&Enum.zip(&1, 1..length(&1)))
    |> Enum.map(&Enum.reduce(&1, 0, fn {{g, a}, b}, acc -> acc + (hash(g, 0) + 1) * a * b end))
    |> Enum.sum()
  end
end
