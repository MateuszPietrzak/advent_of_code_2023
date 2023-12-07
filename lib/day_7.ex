defmodule AdventOfCode2023.Day7.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day7.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def get_score([], _), do: 0

  def get_score([{_, bid} | tail], multiplier) do
    bid * multiplier + get_score(tail, multiplier + 1)
  end

  def get_type_strength(hand) do
    grouped = Enum.sort(hand) |> Enum.chunk_by(fn x -> x end)

    case length(grouped) do
      1 ->
        7

      2 ->
        with [a, b] <- grouped do
          if(length(a) == 1 or length(b) == 1) do
            6
          else
            5
          end
        end

      3 ->
        with [a, b, c] <- grouped do
          if(length(a) == 3 or length(b) == 3 or length(c) == 3) do
            4
          else
            3
          end
        end

      4 ->
        2

      _ ->
        1
    end
  end

  def find_first_difference([], _), do: false

  def find_first_difference([head1 | tail1], [head2 | tail2]) do
    if head1 == head2 do
      find_first_difference(tail1, tail2)
    else
      {head1, head2}
    end
  end
end

defmodule AdventOfCode2023.Day7.Part1 do
  import AdventOfCode2023.Day7.Utility

  def get_letter_strength(char) do
    case char do
      ?A -> 13
      ?K -> 12
      ?Q -> 11
      ?J -> 10
      ?T -> 9
      ?9 -> 8
      ?8 -> 7
      ?7 -> 6
      ?6 -> 5
      ?5 -> 4
      ?4 -> 3
      ?3 -> 2
      ?2 -> 1
      _ -> 0
    end
  end

  def comparator({hand1, _}, {hand2, _}) do
    type_strength_1 = get_type_strength(hand1)
    type_strength_2 = get_type_strength(hand2)

    if(type_strength_1 == type_strength_2) do
      {diff1, diff2} = find_first_difference(hand1, hand2)
      get_letter_strength(diff1) < get_letter_strength(diff2)
    else
      type_strength_1 < type_strength_2
    end
  end

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [hand, bid] -> {String.to_charlist(hand), String.to_integer(bid)} end)
    |> Enum.sort(&comparator/2)
    |> Enum.map(&IO.inspect(&1))
    |> get_score(1)
  end
end

defmodule AdventOfCode2023.Day7.Part2 do
  import AdventOfCode2023.Day7.Utility

  def get_letter_strength(char) do
    case char do
      ?A -> 13
      ?K -> 12
      ?Q -> 11
      ?J -> 0
      ?T -> 9
      ?9 -> 8
      ?8 -> 7
      ?7 -> 6
      ?6 -> 5
      ?5 -> 4
      ?4 -> 3
      ?3 -> 2
      ?2 -> 1
      _ -> 0
    end
  end

  def reduce_hand(hand) do
    index = Enum.find_index(hand, fn x -> x == ?J end)
    list = [?A, ?K, ?Q, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2]

    if index == nil do
      get_type_strength(hand)
    else
      Enum.map(list, fn letter -> List.replace_at(hand, index, letter) end)
      |> Enum.map(&reduce_hand/1)
      |> Enum.max()
    end
  end

  def comparator({hand1, _}, {hand2, _}) do
    type_strength_1 = reduce_hand(hand1)
    type_strength_2 = reduce_hand(hand2)

    if(type_strength_1 == type_strength_2) do
      {diff1, diff2} = find_first_difference(hand1, hand2)
      get_letter_strength(diff1) < get_letter_strength(diff2)
    else
      type_strength_1 < type_strength_2
    end
  end

  def solve do
    get_file()
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [hand, bid] -> {String.to_charlist(hand), String.to_integer(bid)} end)
    |> Enum.sort(&comparator/2)
    |> Enum.map(&IO.inspect(&1))
    |> get_score(1)
  end
end
