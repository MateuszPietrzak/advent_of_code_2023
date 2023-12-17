defmodule AdventOfCode2023.Day16.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day16.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def move(file, row, col, direction, map) do
    repeat = Map.get(map, {row, col, direction})

    if row < 0 or col < 0 or row >= length(file) or col >= length(hd(file)) or repeat do
      map
    else
      cur_map = Map.put(map, {row, col, direction}, true)

      char = Enum.at(Enum.at(file, row), col)

      new_direction =
        case char do
          ?. ->
            direction

          ?| ->
            case direction do
              :right -> :vertical
              :left -> :vertical
              :up -> :up
              :down -> :down
            end

          ?- ->
            case direction do
              :right -> :right
              :left -> :left
              :up -> :horizontal
              :down -> :horizontal
            end

          ?/ ->
            case direction do
              :right -> :up
              :left -> :down
              :up -> :right
              :down -> :left
            end

          ?\\ ->
            case direction do
              :right -> :down
              :left -> :up
              :up -> :left
              :down -> :right
            end
        end

      case new_direction do
        :right ->
          Map.merge(cur_map, move(file, row, col + 1, new_direction, cur_map))

        :left ->
          Map.merge(cur_map, move(file, row, col - 1, new_direction, cur_map))

        :up ->
          Map.merge(cur_map, move(file, row - 1, col, new_direction, cur_map))

        :down ->
          Map.merge(cur_map, move(file, row + 1, col, new_direction, cur_map))

        :vertical ->
          mapv = move(file, row + 1, col, :down, cur_map)
          move(file, row - 1, col, :up, mapv)

        :horizontal ->
          maph = move(file, row, col + 1, :right, cur_map)
          move(file, row, col - 1, :left, maph)
      end
    end
  end
end

defmodule AdventOfCode2023.Day16.Part1 do
  import AdventOfCode2023.Day16.Utility

  def solve do
    get_file()
    |> move(0, 0, :right, %{})
    |> Enum.map(fn {{r, c, _}, _} -> {r, c} end)
    |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, true) end)
    |> Map.to_list()
    |> length()
  end
end

defmodule AdventOfCode2023.Day16.Part2 do
  import AdventOfCode2023.Day16.Utility

  def solve do
    file = get_file()

    l1 =
      Enum.map(0..(length(file) - 1), fn i ->
        move(file, i, 0, :right, %{})
        |> Enum.map(fn {{r, c, _}, _} -> {r, c} end)
        |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, true) end)
        |> Map.to_list()
        |> length()
      end)

    l2 =
      Enum.map(0..(length(file) - 1), fn i ->
        move(file, i, length(hd(file)) - 1, :left, %{})
        |> Enum.map(fn {{r, c, _}, _} -> {r, c} end)
        |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, true) end)
        |> Map.to_list()
        |> length()
      end)

    l3 =
      Enum.map(0..(length(hd(file)) - 1), fn i ->
        move(file, 0, i, :down, %{})
        |> Enum.map(fn {{r, c, _}, _} -> {r, c} end)
        |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, true) end)
        |> Map.to_list()
        |> length()
      end)

    l4 =
      Enum.map(0..(length(hd(file)) - 1), fn i ->
        move(file, length(file) - 1, i, :up, %{})
        |> Enum.map(fn {{r, c, _}, _} -> {r, c} end)
        |> Enum.reduce(%{}, fn x, acc -> Map.put(acc, x, true) end)
        |> Map.to_list()
        |> length()
      end)

    Enum.max([
      Enum.max(l1),
      Enum.max(l2),
      Enum.max(l3),
      Enum.max(l4)
    ])
  end
end
