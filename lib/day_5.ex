defmodule AdventOfCode2023.Day5.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day5.in")

    IO.read(file, :eof)
    |> String.split("\n\n", trim: true)
  end

  def process_transformation(description) do
    description
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.map(fn [d, s, l] ->
      [
        source: s,
        length: l,
        difference: d - s
      ]
    end)
  end

  def get_result(number, []), do: number

  def get_result(number, [transformation | tail]) do
    new_number = transform(number, transformation)
    get_result(new_number, tail)
  end

  def transform(number, transformation) do
    transformation_index =
      transformation
      |> Enum.find_index(fn t ->
        number >= t[:source] and number < t[:source] + t[:length]
      end)

    if transformation_index == nil do
      number
    else
      number + Enum.at(transformation, transformation_index)[:difference]
    end
  end
end

defmodule AdventOfCode2023.Day5.Part1 do
  import AdventOfCode2023.Day5.Utility

  def solve do
    [seeds | transformations] = get_file()

    seed_list =
      seeds
      |> String.split([" ", "seeds: "], trim: true)
      |> Enum.map(&String.to_integer/1)

    transformations_list =
      transformations
      |> Enum.map(&process_transformation/1)

    seed_list
    |> Enum.map(&get_result(&1, transformations_list))
    |> Enum.min()
  end
end

defmodule AdventOfCode2023.Day5.Part2 do
  import AdventOfCode2023.Day5.Utility

  defp get_ranges([]), do: []

  defp get_ranges([beginning, length | tail]) do
    [[beginning: beginning, end: beginning + length - 1] | get_ranges(tail)]
  end

  defp split_with_transformations(range, []) do
    [range]
  end

  defp split_with_transformations(range, [transform | tail]) do
    cond do
      range[:end] < transform[:source] ->
        split_with_transformations(range, tail)

      range[:beginning] >= transform[:source] + transform[:length] ->
        split_with_transformations(range, tail)

      range[:beginning] >= transform[:source] and
          range[:end] < transform[:source] + transform[:length] ->
        [
          [
            beginning: range[:beginning] + transform[:difference],
            end: range[:end] + transform[:difference]
          ]
        ]

      range[:beginning] >= transform[:source] ->
          [[
            beginning: range[:beginning] + transform[:difference],
            end: transform[:source] + transform[:length] - 1 + transform[:difference]
          ]] ++
          split_with_transformations([beginning: transform[:source] + transform[:length], end: range[:end]], tail)

      range[:end] < transform[:source] + transform[:length] ->
          split_with_transformations([beginning: range[:beginning], end: transform[:source] - 1], tail) ++
          [[
            beginning: transform[:source] + transform[:difference],
            end: range[:end] + transform[:difference]
          ]]

      true ->
          split_with_transformations([beginning: range[:beginning], end: transform[:source] - 1], tail) ++
          [[
            beginning: transform[:source] + transform[:difference],
            end: transform[:source] + transform[:length] - 1 + transform[:difference]
          ]] ++
          split_with_transformations([beginning: transform[:source] + transform[:length], end: range[:end]], tail)
    end
  end

  defp get_final_ranges(ranges, []), do: ranges

  defp get_final_ranges(ranges, [transformation | tail]) do
    IO.inspect(ranges, label: "ranges")
    new_ranges =
      ranges
      |> Enum.reduce([], fn x, acc ->
        acc ++
          split_with_transformations(x, transformation)
      end)

    get_final_ranges(new_ranges, tail)
  end

  def solve do
    [seeds | transformations] = get_file()

    seed_ranges =
      seeds
      |> String.split([" ", "seeds: "], trim: true)
      |> Enum.map(&String.to_integer/1)
      |> get_ranges()

    transformations_list =
      transformations
      |> Enum.map(&process_transformation/1)

    seed_ranges
    |> get_final_ranges(transformations_list)
    |> IO.inspect(label: "final ranges")
    |> Enum.reduce([], fn [beginning: a, end: b], acc -> acc ++ [a] ++ [b] end)
    |> Enum.min()
  end
end
