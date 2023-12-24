defmodule AdventOfCode2023.Day23.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day23.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end
end

defmodule AdventOfCode2023.Day23.Part1 do
  import AdventOfCode2023.Day23.Utility

  def dfs(file, row, col, from_row, from_col, depth) do
    cur = Enum.at(Enum.at(file, row, []), col, 35)

    if row < 0 or col < 0 or row >= length(file) or col >= length(hd(file)) or cur == 35 or
         (cur == ?^ and from_row == row - 1) or
         (cur == ?v and from_row == row + 1) or
         (cur == ?< and from_col == col - 1) or
         (cur == ?> and from_col == col + 1) do
      0
    else
      if row == length(file) - 1 do
        depth
      else
        Enum.max([
          if(from_row == row + 1, do: 0, else: dfs(file, row + 1, col, row, col, depth + 1)),
          if(from_row == row - 1, do: 0, else: dfs(file, row - 1, col, row, col, depth + 1)),
          if(from_col == col + 1, do: 0, else: dfs(file, row, col + 1, row, col, depth + 1)),
          if(from_col == col - 1, do: 0, else: dfs(file, row, col - 1, row, col, depth + 1))
        ])
      end
    end
  end

  def solve do
    file = get_file()

    dfs(file, 0, 1, -1, -1, 0)
  end
end

defmodule AdventOfCode2023.Day23.Part2 do
  import AdventOfCode2023.Day23.Utility

  def find_junctions(file, row, col) do
    cur = Enum.at(Enum.at(file, row, []), col, ?#)

    paths =
      if(Enum.at(Enum.at(file, row + 1, []), col, ?#) == ?#, do: 0, else: 1) +
        if(Enum.at(Enum.at(file, row - 1, []), col, ?#) == ?#, do: 0, else: 1) +
        if(Enum.at(Enum.at(file, row, []), col + 1, ?#) == ?#, do: 0, else: 1) +
        if Enum.at(Enum.at(file, row, []), col - 1, ?#) == ?#, do: 0, else: 1

    if cur == ?. and paths > 2 do
      {row, col}
    else
      []
    end
  end

  def find_connected(file, row, col, from_row, from_col, depth, beg_row, beg_col, junctions_map) do
    cur = Enum.at(Enum.at(file, row, []), col, ?#)

    if row < 0 or col < 0 or row >= length(file) or col >= length(hd(file)) or cur == ?# do
      []
    else
      if Map.get(junctions_map, {row, col}) != nil and (row != beg_row or col != beg_col) do
        [{{row, col}, depth}]
      else
        if(from_row == row + 1,
          do: [],
          else:
            find_connected(
              file,
              row + 1,
              col,
              row,
              col,
              depth + 1,
              beg_row,
              beg_col,
              junctions_map
            )
        ) ++
          if(from_row == row - 1,
            do: [],
            else:
              find_connected(
                file,
                row - 1,
                col,
                row,
                col,
                depth + 1,
                beg_row,
                beg_col,
                junctions_map
              )
          ) ++
          if(from_col == col + 1,
            do: [],
            else:
              find_connected(
                file,
                row,
                col + 1,
                row,
                col,
                depth + 1,
                beg_row,
                beg_col,
                junctions_map
              )
          ) ++
          if(from_col == col - 1,
            do: [],
            else:
              find_connected(
                file,
                row,
                col - 1,
                row,
                col,
                depth + 1,
                beg_row,
                beg_col,
                junctions_map
              )
          )
      end
    end
  end

  def dfs(junctions, row, col, from_row, from_col, depth, tar_row, tar_col) do
    if row == from_row and col == from_col do
      0
    else
      new_junctions = Map.delete(junctions, {row, col})
      new_list = Map.get(junctions, {row, col})

      cond do
        row == tar_row and col == tar_col ->
          depth

        new_list == nil ->
          0

        true ->
          new_list
          |> Enum.map(fn {{n_row, n_col}, delta} ->
            dfs(new_junctions, n_row, n_col, row, col, depth + delta, tar_row, tar_col)
          end)
          |> Enum.max()
      end
    end
  end

  def solve do
    file =
      get_file()
      |> Enum.map(&Enum.map(&1, fn x -> if x == ?#, do: ?#, else: ?. end))

    junctions_map =
      Enum.reduce(
        for row <- 0..(length(file) - 1), col <- 0..(length(hd(file)) - 1) do
          find_junctions(file, row, col)
        end,
        %{},
        fn x, acc -> if x == [], do: acc, else: Map.put(acc, x, []) end
      )
      |> Map.put({0, 1}, [])
      |> Map.put({length(file) - 1, length(hd(file)) - 2}, [])

    junctions =
      Enum.map(junctions_map, fn {{row, col}, _} ->
        {{row, col}, find_connected(file, row, col, -1, -1, 0, row, col, junctions_map)}
      end)
      |> Enum.into(%{})

    dfs(junctions, 0, 1, -1, -1, 0, length(file) - 1, length(hd(file)) - 2)
  end
end
