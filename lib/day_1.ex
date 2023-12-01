defmodule AdventOfCode2023.Day1.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day1.in")
    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end
end

defmodule AdventOfCode2023.Day1.Part1 do
  alias AdventOfCode2023.Day1.Utility

  def solve do
    file = Utility.get_file()
    file
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(fn list -> Enum.filter(list, fn c -> c >= ?0 and c <= ?9 end) end)
    |> Enum.map(fn list -> [List.first(list), List.last(list)] end)
    |> Enum.map(&List.to_integer/1)
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day1.Part2 do
  alias AdventOfCode2023.Day1.Utility

  def text_to_digits(x) do
    cond do
      x == [] -> [] 

      List.starts_with?(x, 'one') -> 
        with [_ | tail] <- x, do: [?1 | text_to_digits(tail)]
      List.starts_with?(x, 'two') -> 
        with [_ | tail] <- x, do: [?2 | text_to_digits(tail)]
      List.starts_with?(x, 'three') -> 
        with [_ | tail] <- x, do: [?3 | text_to_digits(tail)]
      List.starts_with?(x, 'four') -> 
        with [_ | tail] <- x, do: [?4 | text_to_digits(tail)]
      List.starts_with?(x, 'five') -> 
        with [_ | tail] <- x, do: [?5 | text_to_digits(tail)]
      List.starts_with?(x, 'six') -> 
        with [_ | tail] <- x, do: [?6 | text_to_digits(tail)]
      List.starts_with?(x, 'seven') -> 
        with [_ | tail] <- x, do: [?7 | text_to_digits(tail)]
      List.starts_with?(x, 'eight') -> 
        with [_ | tail] <- x, do: [?8 | text_to_digits(tail)]
      List.starts_with?(x, 'nine') -> 
        with [_ | tail] <- x, do: [?9 | text_to_digits(tail)]

      true ->
        with [head | tail] <- x, do: [head | text_to_digits(tail)]
    end
  end


  def solve do
    file = Utility.get_file()
    file
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&text_to_digits/1)
    |> Enum.map(fn list -> Enum.filter(list, fn c -> c >= ?0 and c <= ?9 end) end)
    |> Enum.map(fn list -> [List.first(list), List.last(list)] end)
    |> Enum.map(&List.to_integer/1)
    |> Enum.sum()
  end
end
