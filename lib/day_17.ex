defmodule AdventOfCode2023.Day17.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day17.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&Enum.map(&1, fn x -> x - ?0 end))
  end
end

defmodule AdventOfCode2023.Day17.Part1 do
  import AdventOfCode2023.Day17.Utility

  def get_next_pos(map) do
    {key, _} = Enum.min_by(map, fn {{_, _, _, _, res}, _} -> res end)
    key
  end

  def find_path(file, row, col, direction, straight, res, map, odl) do
    if row < 0 or col < 0 or row >= length(file) or col >= length(hd(file)) or straight > 3 do
      {_, next_map} = Map.pop(map, {row, col, direction, straight, res})

      if map_size(next_map) > 0 do
        {next_row, next_col, next_direction, next_straight, next_res} = get_next_pos(next_map)

        find_path(
          file,
          next_row,
          next_col,
          next_direction,
          next_straight,
          next_res,
          next_map,
          odl
        )
      else
        odl
      end
    else
      if Map.get(odl, {row, col, direction, straight}) != nil and
           Map.get(odl, {row, col, direction, straight}, 1_000_000_000) <= res do
        {_, next_map} = Map.pop(map, {row, col, direction, straight, res})

        if map_size(next_map) > 0 do
          {next_row, next_col, next_direction, next_straight, next_res} = get_next_pos(next_map)

          find_path(
            file,
            next_row,
            next_col,
            next_direction,
            next_straight,
            next_res,
            next_map,
            odl
          )
        else
          odl
        end
      else
        new_map =
          Map.merge(map, %{
            {row - 1, col, :up,
             case direction do
               :up -> straight + 1
               :down -> 4
               _ -> 1
             end, res + Enum.at(Enum.at(file, row - 1, []), col, 0)} => true,
            {row + 1, col, :down,
             case direction do
               :down -> straight + 1
               :up -> 4
               _ -> 1
             end, res + Enum.at(Enum.at(file, row + 1, []), col, 0)} => true,
            {row, col - 1, :left,
             case direction do
               :left -> straight + 1
               :right -> 4
               _ -> 1
             end, res + Enum.at(Enum.at(file, row, []), col - 1, 0)} => true,
            {row, col + 1, :right,
             case direction do
               :right -> straight + 1
               :left -> 4
               _ -> 1
             end, res + Enum.at(Enum.at(file, row, []), col + 1, 0)} => true
          })

        new_odl = Map.put(odl, {row, col, direction, straight}, res)

        {_, next_map} = Map.pop(new_map, {row, col, direction, straight})

        if map_size(next_map) > 0 do
          {next_row, next_col, next_direction, next_straight, next_res} = get_next_pos(next_map)

          find_path(
            file,
            next_row,
            next_col,
            next_direction,
            next_straight,
            next_res,
            next_map,
            new_odl
          )
        else
          new_odl
        end
      end
    end
  end

  def solve do
    file = get_file()

    map =
      file
      |> find_path(0, 0, :none, 0, 0, %{{0, 0, :none, 0} => 0}, %{})

    row = length(file) - 1
    col = length(hd(file)) - 1

    # IO.inspect(map)

    Enum.min([
      Map.get(map, {row, col, :right, 1}),
      Map.get(map, {row, col, :right, 2}),
      Map.get(map, {row, col, :right, 3}),
      Map.get(map, {row, col, :down, 1}),
      Map.get(map, {row, col, :down, 2}),
      Map.get(map, {row, col, :down, 3})
    ])
  end
end

defmodule AdventOfCode2023.Day17.Part2 do
  import AdventOfCode2023.Day17.Utility

  def get_next_pos(map) do
    {key, _} = Enum.min_by(map, fn {{_, _, _, _, res}, _} -> res end)
    key
  end

  def find_path(file, row, col, direction, straight, res, map, odl) do
    if row < 0 or col < 0 or row >= length(file) or col >= length(hd(file)) or straight > 10 do
      {_, next_map} = Map.pop(map, {row, col, direction, straight, res})

      if map_size(next_map) > 0 do
        {next_row, next_col, next_direction, next_straight, next_res} = get_next_pos(next_map)

        find_path(
          file,
          next_row,
          next_col,
          next_direction,
          next_straight,
          next_res,
          next_map,
          odl
        )
      else
        odl
      end
    else
      if Map.get(odl, {row, col, direction, straight}) != nil and
           Map.get(odl, {row, col, direction, straight}, 1_000_000_000) <= res do
        {_, next_map} = Map.pop(map, {row, col, direction, straight, res})

        if map_size(next_map) > 0 do
          {next_row, next_col, next_direction, next_straight, next_res} = get_next_pos(next_map)

          find_path(
            file,
            next_row,
            next_col,
            next_direction,
            next_straight,
            next_res,
            next_map,
            odl
          )
        else
          odl
        end
      else
        new_map =
          Map.merge(map, %{
            {row - 1, col, :up,
             case direction do
               :up -> straight + 1
               :down -> 11
               :none -> 1
               _ -> if straight < 4, do: 11, else: 1
             end, res + Enum.at(Enum.at(file, row - 1, []), col, 0)} => true,
            {row + 1, col, :down,
             case direction do
               :down -> straight + 1
               :up -> 11
               :none -> 1
               _ -> if straight < 4, do: 11, else: 1
             end, res + Enum.at(Enum.at(file, row + 1, []), col, 0)} => true,
            {row, col - 1, :left,
             case direction do
               :left -> straight + 1
               :right -> 11
               :none -> 1
               _ -> if straight < 4, do: 11, else: 1
             end, res + Enum.at(Enum.at(file, row, []), col - 1, 0)} => true,
            {row, col + 1, :right,
             case direction do
               :right -> straight + 1
               :left -> 11
               :none -> 1
               _ -> if straight < 4, do: 11, else: 1
             end, res + Enum.at(Enum.at(file, row, []), col + 1, 0)} => true
          })

        new_odl = Map.put(odl, {row, col, direction, straight}, res)

        {_, next_map} = Map.pop(new_map, {row, col, direction, straight})

        if map_size(next_map) > 0 do
          {next_row, next_col, next_direction, next_straight, next_res} = get_next_pos(next_map)

          find_path(
            file,
            next_row,
            next_col,
            next_direction,
            next_straight,
            next_res,
            next_map,
            new_odl
          )
        else
          new_odl
        end
      end
    end
  end

  def solve do
    file = get_file()

    map =
      file
      |> find_path(0, 0, :none, 0, 0, %{{0, 0, :none, 0} => 0}, %{})

    row = length(file) - 1
    col = length(hd(file)) - 1

    Enum.min([
      Enum.min(Enum.map(4..10, &Map.get(map, {row, col, :right, &1}))),
      Enum.min(Enum.map(4..10, &Map.get(map, {row, col, :down, &1})))
    ])
  end
end
