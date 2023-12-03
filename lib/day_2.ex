defmodule AdventOfCode2023.Day2.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day2.in")
    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def find_max(draw, acc) do
    acc = %{acc | red: max(draw.red, acc.red)}
    acc = %{acc | green: max(draw.green, acc.green)}
    %{acc | blue: max(draw.blue, acc.blue)}
  end

  def process_color(color) do
    cond do
      String.ends_with?(color, "red") ->
        with amount <- color |> String.trim_trailing(" red") |> String.to_integer() do
          {:red, amount}
        end
      String.ends_with?(color, "green") ->
        with amount <- color |> String.trim_trailing(" green") |> String.to_integer() do
          {:green, amount}
        end
      String.ends_with?(color, "blue") ->
        with amount <- color |> String.trim_trailing(" blue") |> String.to_integer() do
          {:blue, amount}
        end
      true ->
        {:error, "no color matched!"}
    end
  end

  def process_draw(draw) do
    draw
    |> String.split(", ")
    |> Enum.map(&process_color/1)
  end
end

defmodule AdventOfCode2023.Day2.Part1 do
  import AdventOfCode2023.Day2.Utility

  def is_possible?(draw) do
    draw.red <= 12 and draw.green <= 13 and draw.blue <= 14
  end

  def split(line) do
    {id, data} = line
    |> String.split(": ")
    |> List.to_tuple()

    id = 
      id
      |> String.trim_leading("Game ")
      |> String.to_integer()

    is_possible = 
      data
      |> String.split("; ")
      |> Enum.map(&process_draw/1)
      |> Enum.map(&Enum.into(&1, %{red: 0, green: 0, blue: 0}))
      |> Enum.reduce(%{red: 0, green: 0, blue: 0}, &find_max/2)
      |> is_possible?()

    if is_possible, do: id, else: 0
  end

  def solve do
    get_file()
    |> Enum.map(&split/1)
    |> Enum.sum()
  end
end


defmodule AdventOfCode2023.Day2.Part2 do
  import AdventOfCode2023.Day2.Utility

  def find_power(game) do
    game.red * game.green * game.blue
  end

  def split(line) do
    {_, data} = line
    |> String.split(": ")
    |> List.to_tuple()

    data
      |> String.split("; ")
      |> Enum.map(&process_draw/1)
      |> Enum.map(&Enum.into(&1, %{red: 0, green: 0, blue: 0}))
      |> Enum.reduce(%{red: 0, green: 0, blue: 0}, &find_max/2)
      |> find_power()
  end

  def solve do
    get_file()
    |> Enum.map(&split/1)
    |> Enum.sum()
  end
end
