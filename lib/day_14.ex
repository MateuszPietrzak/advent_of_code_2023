defmodule AdventOfCode2023.Day14.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day14.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end
end

defmodule AdventOfCode2023.Day14.Part1 do
  import AdventOfCode2023.Day14.Utility

  def roll([], _, _), do: 0

  def roll([head | tail], row, points) do
    case head do
      ?. -> roll(tail, row - 1, points)
      ?O -> points + roll(tail, row - 1, points - 1)
      _ -> roll(tail, row - 1, row - 1)
    end
  end

  def solve do
    file = get_file()

    file
    |> Enum.map(&String.to_charlist/1)
    |> Enum.reduce(List.duplicate([], length(file)), fn x, acc ->
      Enum.zip(x, acc) |> Enum.map(fn {v1, v2} -> [v1 | v2] end)
    end)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&roll(&1, length(file), length(file)))
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day14.Part2 do
  import AdventOfCode2023.Day14.Utility

  def rotate(file, clockwise \\ true) do
    if clockwise do
      file
      |> Enum.reduce(List.duplicate([], length(file)), fn x, acc ->
        Enum.zip(x, acc) |> Enum.map(fn {v1, v2} -> [v1 | v2] end)
      end)
    else
      file
      |> Enum.reduce(List.duplicate([], length(file)), fn x, acc ->
        Enum.zip(x, acc) |> Enum.map(fn {v1, v2} -> [v1 | v2] end)
      end)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.reverse()
    end
  end

  def roll_left(line, ind, roll_target) do
    cond do
      ind == length(line) ->
        line

      Enum.at(line, ind) == ?. ->
        roll_left(line, ind + 1, roll_target)

      Enum.at(line, ind) == ?O ->
        # IO.puts("Swapping elemens " <> Integer.to_string(roll_target) <> " and " <> Integer.to_string(ind))
        roll_left(
          line |> List.replace_at(ind, ?.) |> List.replace_at(roll_target, ?O),
          ind + 1,
          roll_target + 1
        )

      true ->
        roll_left(line, ind + 1, ind + 1)
    end
  end

  def roll_and_rotate(file, 0), do: file

  def roll_and_rotate(file, num) do
    file
    # |> Enum.map(&IO.inspect/1)
    |> Enum.map(&roll_left(&1, 0, 0))
    |> rotate()
    |> roll_and_rotate(num - 1)
  end

  def get_key(file) do
    file |> Enum.reduce(fn acc, x -> acc ++ x end) |> List.to_string()
  end

  def find_cycle(file, num, map) do
    key = get_key(file)
    loop_ind = Map.get(map, key)

    if loop_ind do
      {loop_ind, num}
    else
      after_cycle =
        file
        |> roll_and_rotate(4)

      find_cycle(after_cycle, num + 1, Map.put(map, get_key(file), num))
    end
  end

  def cycle(file, 0), do: file

  def cycle(file, num) do
    after_cycle =
      file
      |> roll_and_rotate(4)

    cycle(after_cycle, num - 1)
  end

  def get_line_score([], _), do: 0

  def get_line_score([head | tail], score) do
    if head == ?O do
      score + get_line_score(tail, score - 1)
    else
      get_line_score(tail, score - 1)
    end
  end

  def solve do
    file =
      get_file()
      |> Enum.map(&String.to_charlist/1)
      |> rotate(false)

    {cycle_beginning, cycle_end} =
      file
      |> find_cycle(0, %{})
      |> IO.inspect(label: "loop")

    to_cycle =
      (cycle_beginning + rem(1_000_000_000 - cycle_beginning, cycle_end - cycle_beginning))
      |> IO.inspect(label: "to cycle")

    cycle(file, to_cycle)
    |> Enum.map(&get_line_score(&1, length(file)))
    |> Enum.sum()
  end
end
