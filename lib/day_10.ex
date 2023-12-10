defmodule AdventOfCode2023.Day10.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day10.in")

    IO.read(file, :eof)
  end
end

defmodule AdventOfCode2023.Day10.Part1 do
  import AdventOfCode2023.Day10.Utility

  def dfs(file, current_position, came_from, line_length) do
    if Enum.at(file, current_position) == ?S do
      cond do
        current_position - 1 >= 0 and Enum.at(file, current_position - 1) in [?F, ?L, ?-] ->
          1 + dfs(file, current_position - 1, current_position, line_length)

        current_position - line_length >= 0 and
            Enum.at(file, current_position - line_length) in [?F, ?7, ?|] ->
          1 + dfs(file, current_position - line_length, current_position, line_length)

        Enum.at(file, current_position + 1) in [?7, ?J, ?-] ->
          1 + dfs(file, current_position + 1, current_position, line_length)

        Enum.at(file, current_position + line_length) in [?L, ?J, ?|] ->
          1 + dfs(file, current_position + line_length, current_position, line_length)

        true ->
          0
      end
    else
      cond do
        current_position - 1 != came_from and current_position >= 0 and
          Enum.at(file, current_position - 1) in [?F, ?L, ?-] and
            Enum.at(file, current_position) in [?-, ?J, ?7] ->
          1 + dfs(file, current_position - 1, current_position, line_length)

        current_position - line_length != came_from and current_position - line_length >= 0 and
          Enum.at(file, current_position - line_length) in [?F, ?7, ?|] and
            Enum.at(file, current_position) in [?|, ?L, ?J] ->
          1 + dfs(file, current_position - line_length, current_position, line_length)

        current_position + 1 != came_from and Enum.at(file, current_position + 1) in [?7, ?J, ?-] and
            Enum.at(file, current_position) in [?F, ?L, ?-] ->
          1 + dfs(file, current_position + 1, current_position, line_length)

        current_position + line_length != came_from and
          Enum.at(file, current_position + line_length) in [?L, ?J, ?|] and
            Enum.at(file, current_position) in [?F, ?7, ?|] ->
          1 + dfs(file, current_position + line_length, current_position, line_length)

        true ->
          0
      end
    end
  end

  def solve do
    file = get_file() |> String.to_charlist()

    line_length =
      file
      |> Enum.find_index(fn x -> x == ?\n end)
      |> Kernel.+(1)

    starting_position =
      file
      |> Enum.find_index(fn x -> x == ?S end)

    div(dfs(file, starting_position, nil, line_length) + 1, 2)
  end
end

defmodule AdventOfCode2023.Day10.Part2 do
  import AdventOfCode2023.Day10.Utility

  def mark(file, position, line_length) do
    case Enum.at(file, position) do
      ?F ->
        List.replace_at(file, position, ?f)

      ?7 ->
        List.replace_at(file, position, ?s)

      ?L ->
        List.replace_at(file, position, ?l)

      ?J ->
        List.replace_at(file, position, ?j)

      ?| ->
        List.replace_at(file, position, ?i)

      ?S ->
        List.replace_at(
          file,
          position,
          cond do
            position - line_length >= 0 and Enum.at(file, position - 1) in [?F, ?L, ?-] and Enum.at(file, position - line_length) in [?F, ?7, ?|] ->
              ?j

            position - line_length >= 0 and Enum.at(file, position + 1) in [?7, ?J, ?-] and Enum.at(file, position - line_length) in [?F, ?7, ?|] ->
              ?l

            Enum.at(file, position + 1) in [?7, ?J, ?-] and Enum.at(file, position + line_length) in [?L, ?J, ?|] ->
              ?f

            position - 1 >= 0 and Enum.at(file, position - 1) in [?F, ?L, ?-] and Enum.at(file, position + line_length) in [?L, ?J, ?|] ->
              ?s

            position - line_length >= 0 and Enum.at(file, position - line_length) in [?7, ?F, ?|] and Enum.at(file, position + line_length) in [?L, ?J, ?|] ->
              ?i

            true ->
              ?n
          end
        )

      ?- ->
        List.replace_at(file, position, ?n)

      _ ->
        List.replace_at(file, position, ?.)
    end
  end

  def dfs(file, current_position, came_from, line_length) do
    if Enum.at(file, current_position) == ?S do
      cond do
        current_position - 1 >= 0 and Enum.at(file, current_position - 1) in [?F, ?L, ?-] ->
          dfs(mark(file, current_position, line_length), current_position - 1, current_position, line_length)

        current_position - line_length >= 0 and
            Enum.at(file, current_position - line_length) in [?F, ?7, ?|] ->
          dfs(
            mark(file, current_position, line_length),
            current_position - line_length,
            current_position,
            line_length
          )

        Enum.at(file, current_position + 1) in [?7, ?J, ?-] ->
          dfs(mark(file, current_position, line_length), current_position + 1, current_position, line_length)

        Enum.at(file, current_position + line_length) in [?L, ?J, ?|] ->
          dfs(
            mark(file, current_position, line_length),
            current_position + line_length,
            current_position,
            line_length
          )

        true ->
          :error
      end
    else
      cond do
        current_position - 1 != came_from and current_position >= 0 and
          Enum.at(file, current_position - 1) in [?F, ?L, ?-] and
            Enum.at(file, current_position) in [?-, ?J, ?7] ->
          dfs(mark(file, current_position, line_length), current_position - 1, current_position, line_length)

        current_position - line_length != came_from and current_position - line_length >= 0 and
          Enum.at(file, current_position - line_length) in [?F, ?7, ?|] and
            Enum.at(file, current_position) in [?|, ?L, ?J] ->
          dfs(
            mark(file, current_position, line_length),
            current_position - line_length,
            current_position,
            line_length
          )

        current_position + 1 != came_from and Enum.at(file, current_position + 1) in [?7, ?J, ?-] and
            Enum.at(file, current_position) in [?F, ?L, ?-] ->
          dfs(mark(file, current_position, line_length), current_position + 1, current_position, line_length)

        current_position + line_length != came_from and
          Enum.at(file, current_position + line_length) in [?L, ?J, ?|] and
            Enum.at(file, current_position) in [?F, ?7, ?|] ->
          dfs(
            mark(file, current_position, line_length),
            current_position + line_length,
            current_position,
            line_length
          )

        true ->
          mark(file, current_position, line_length)
      end
    end
  end

  def calculate_score([], _, _), do: 0

  def calculate_score([head | tail], count, prev_turn) do
    cond do
      head == ?f -> calculate_score(tail, count, ?f)
      head == ?l -> calculate_score(tail, count, ?l)
      head == ?s and prev_turn == ?f -> calculate_score(tail, count, nil)
      head == ?s and prev_turn == ?l -> calculate_score(tail, count + 1, nil)
      head == ?j and prev_turn == ?l -> calculate_score(tail, count, nil)
      head == ?j and prev_turn == ?f -> calculate_score(tail, count + 1, nil)
      head == ?i -> calculate_score(tail, count + 1, nil)
      head == ?n -> calculate_score(tail, count, prev_turn)
      rem(count, 2) == 1 -> 1 + calculate_score(tail, count, nil)
      true -> calculate_score(tail, count, nil)
    end
  end

  def solve do
    file = get_file() |> String.to_charlist()

    line_length =
      file
      |> Enum.find_index(fn x -> x == ?\n end)
      |> Kernel.+(1)

    starting_position =
      file
      |> Enum.find_index(fn x -> x == ?S end)

    res = file
    |> dfs(starting_position, nil, line_length)
    |> List.to_string()
    |> String.split("\n", trim: true)

    res
    |> Enum.map(&calculate_score(String.to_charlist(&1),0,nil))
    |> Enum.sum()
  end
end
