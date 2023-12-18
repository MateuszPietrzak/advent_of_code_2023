defmodule AdventOfCode2023.Day18.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day18.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def triangle_area(x1, y1, x2, y2) do
    x1 * y2 + x2 * -y1
  end

  def get_area([], _, _), do: 0

  def get_area([{direction, length} | tail], x, y) do
    nx =
      case direction do
        :left -> x - length
        :right -> x + length
        _ -> x
      end

    ny =
      case direction do
        :up -> y - length
        :down -> y + length
        _ -> y
      end

    length + triangle_area(x, y, nx, ny) + get_area(tail, nx, ny)
  end
end

defmodule AdventOfCode2023.Day18.Part1 do
  import AdventOfCode2023.Day18.Utility

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [dir, length, _] ->
      {case dir do
         "R" -> :right
         "L" -> :left
         "U" -> :up
         "D" -> :down
       end, String.to_integer(length)}
    end)
    |> get_area(0, 0)
    |> div(2)
    |> Kernel.+(1)
  end
end

defmodule AdventOfCode2023.Day18.Part2 do
  import AdventOfCode2023.Day18.Utility

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, [" (#", ")"], trim: true))
    |> Enum.map(fn [_, info] -> String.to_charlist(info) end)
    |> Enum.map(fn x ->
      {case Enum.drop(x, 5) do
         ~c"0" -> :right
         ~c"1" -> :down
         ~c"2" -> :left
         ~c"3" -> :up
       end, Enum.take(x, 5) |> List.to_string() |> String.to_integer(16)}
    end)
    |> get_area(0, 0)
    |> div(2)
    |> Kernel.+(1)
  end
end
