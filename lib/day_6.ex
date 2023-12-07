defmodule AdventOfCode2023.Day6.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day6.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def get_result({t, d}) do
    x1 = (t - Float.pow(t * t - 4.0 * d, 0.5)) / 2.0 + 0.000001
    x2 = (t + Float.pow(t * t - 4.0 * d, 0.5)) / 2.0 - 0.000001
    floor(x2) - ceil(x1) + 1
  end
end

defmodule AdventOfCode2023.Day6.Part1 do
  import AdventOfCode2023.Day6.Utility

  def solve do
    [time, distance] =
      get_file()
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(&Enum.drop(&1, 1))
      |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)

    Enum.zip(time, distance)
    |> Enum.map(&get_result/1)
    |> Enum.product()
  end
end

defmodule AdventOfCode2023.Day6.Part2 do
  import AdventOfCode2023.Day6.Utility

  def solve do
    [time, distance] =
      get_file()
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.map(&Enum.drop(&1, 1))
      |> Enum.map(&Enum.reduce(&1, "", fn x, acc -> acc <> x end))
      |> Enum.map(&String.to_integer/1)

    get_result({time, distance})
  end
end
