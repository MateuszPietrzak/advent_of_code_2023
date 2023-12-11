defmodule AdventOfCode2023.Day11.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day11.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.to_charlist(x) end)
  end
end

defmodule AdventOfCode2023.Day11.Part1 do
  import AdventOfCode2023.Day11.Utility

  def get_zero_cols(file) do
    if(length(hd(file)) == 0) do
      []
    else
      [Enum.all?(file, fn [head | _] -> head == ?. end)] ++
        get_zero_cols(Enum.map(file, fn [_ | tail] -> tail end))
    end
  end

  def expand(file) do
    zero_cols = get_zero_cols(file)

    file
    |> Enum.reduce([], fn line, acc ->
      if line |> Enum.all?(fn x -> x == ?. end),
        do: acc ++ [line, line],
        else: acc ++ [line]
    end)
    |> Enum.map(fn line -> Enum.zip(line, zero_cols) end)
    |> Enum.map(fn line ->
      Enum.reduce(line, [], fn {char, empty_line}, acc ->
        if !empty_line, do: acc ++ [char], else: acc ++ [char, char]
      end)
    end)
  end

  def calculate_length([]), do: 0

  def calculate_length([{cx, cy} | tail]) do
    Enum.map(tail, fn {x, y} -> abs(cx - x) + abs(cy - y) end)
    |> Enum.sum()
    |> Kernel.+(calculate_length(tail))
  end

  def solve do
    file =
      get_file()
      |> expand()

    Enum.zip(file, 0..(length(file) - 1))
    |> Enum.map(fn {line, row_nr} ->
      Enum.zip(line, 0..(length(line) - 1))
      |> Enum.reduce([], fn {char, col_nr}, acc ->
        if char == 35, do: acc ++ [{row_nr, col_nr}], else: acc
      end)
    end)
    |> Enum.reduce(fn x, acc -> acc ++ x end)
    |> calculate_length()
  end
end

defmodule AdventOfCode2023.Day11.Part2 do
  import AdventOfCode2023.Day11.Utility

  def get_zero_cols(file) do
    if(length(hd(file)) == 0) do
      []
    else
      [Enum.all?(file, fn [head | _] -> head == ?. end)] ++
        get_zero_cols(Enum.map(file, fn [_ | tail] -> tail end))
    end
  end

  def get_expansions(file) do
    zero_cols = get_zero_cols(file)

    {file
     |> Enum.map(fn line ->
       if line |> Enum.all?(fn x -> x == ?. end),
         do: true,
         else: false
     end), zero_cols}
  end

  def calculate_length([]), do: 0

  def calculate_length([{cx, cy} | tail]) do
    Enum.map(tail, fn {x, y} -> abs(cx - x) + abs(cy - y) end)
    |> Enum.sum()
    |> Kernel.+(calculate_length(tail))
  end

  def assign_col_coords([], _, _, _), do: []

  def assign_col_coords([head | tail], [zero_cols_head | zero_cols_tail], col_cnt, row_cnt) do
    if head == 35 do
      [{row_cnt, col_cnt}] ++
        assign_col_coords(
          tail,
          zero_cols_tail,
          if(zero_cols_head, do: col_cnt + 1_000_000, else: col_cnt + 1),
          row_cnt
        )
    else
      assign_col_coords(
        tail,
        zero_cols_tail,
        if(zero_cols_head, do: col_cnt + 1_000_000, else: col_cnt + 1),
        row_cnt
      )
    end
  end

  def assign_coords([], _, _, _), do: []

  def assign_coords([first_row | tail], [zero_rows_head | zero_rows_tail], zero_cols, row_cnt) do
    row_res = assign_col_coords(first_row, zero_cols, 0, row_cnt)

    [row_res] ++
      assign_coords(
        tail,
        zero_rows_tail,
        zero_cols,
        if(zero_rows_head, do: row_cnt + 1_000_000, else: row_cnt + 1)
      )
  end

  def solve do
    file =
      get_file()

    {zero_rows, zero_cols} = get_expansions(file)

    assign_coords(file, zero_rows, zero_cols, 0)
    |> Enum.reduce(fn x, acc -> acc ++ x end)
    |> calculate_length()
  end
end
