defmodule AdventOfCode2023.Day13.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day13.in")

    IO.read(file, :eof)
    |> String.split("\n\n", trim: true)
  end

  def get_row_hash([]), do: 0

  def get_row_hash([head | tail]) do
    if head == ?. do
      2 * get_row_hash(tail)
    else
      1 + 2 * get_row_hash(tail)
    end
  end

  def get_cols_hash(grid = [head | _], line_length) do
    if length(head) == 0 do
      []
    else
      [ Enum.map(grid, fn [h | _] -> h end) |> Enum.reduce(0, fn x, acc -> 2 * acc + (if x == ?., do: 0, else: 1) end) |
        Enum.map(grid, fn [_ | t] -> t end)
      |> get_cols_hash(line_length)]

    end
  end

end

defmodule AdventOfCode2023.Day13.Part1 do
  import AdventOfCode2023.Day13.Utility


  def check_palindrome(list, ai, bi) do
    cond do
      ai == 0 -> true
      bi == length(list) + 1 -> true
      true -> Enum.at(list, ai-1) == Enum.at(list, bi-1) && check_palindrome(list, ai-1, bi+1)
    end
  end

  def get_potential_palindromes([_], _), do: 0

  def get_potential_palindromes([{_, ai}, {b, bi} | tail], list) do
    if check_palindrome(list, ai, bi) do
      ai
    else
      get_potential_palindromes([{b, bi} | tail], list)
    end
  end

  def get_score(grid) do
    parsed_grid =
      grid
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    cols_hash =
      parsed_grid
      |> get_cols_hash(
        String.split(grid, "\n", trim: true)
        |> hd()
        |> String.to_charlist()
        |> length()
      )

    rows_hash =
      parsed_grid
      |> Enum.map(&get_row_hash/1)

    col_res = cols_hash
    |> Enum.zip(1..length(cols_hash))
    |> get_potential_palindromes(cols_hash)

    row_res = rows_hash
    |> Enum.zip(1..length(rows_hash))
    |> get_potential_palindromes(rows_hash)

    col_res + row_res * 100
  end

  def solve do
    get_file()
    |> Enum.map(&get_score/1)
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day13.Part2 do
  import AdventOfCode2023.Day13.Utility

  def count_bits(0), do: 0

  def count_bits(number) do
    rem(number,2) + count_bits(div(number, 2))
  end

  def one_bit_on?(number) do
    count_bits(number) == 1
  end

  def check_palindrome(list, ai, bi, found_smudge) do
    cond do
      ai == 0 -> found_smudge
      bi == length(list) + 1 -> found_smudge
      Enum.at(list, ai-1) == Enum.at(list, bi-1) -> check_palindrome(list, ai-1, bi+1, found_smudge)
      !found_smudge && Bitwise.bxor(Enum.at(list, ai-1), Enum.at(list, bi-1)) |> one_bit_on?() -> check_palindrome(list, ai-1, bi+1, true)
      true -> false
    end
  end

  def get_potential_palindromes([_], _), do: 0

  def get_potential_palindromes([{_, ai}, {b, bi} | tail], list) do
    if check_palindrome(list, ai, bi, false) do
      ai
    else
      get_potential_palindromes([{b, bi} | tail], list)
    end
  end

  def get_score(grid) do
    parsed_grid =
      grid
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    cols_hash =
      parsed_grid
      |> get_cols_hash(
        String.split(grid, "\n", trim: true)
        |> hd()
        |> String.to_charlist()
        |> length()
      )

    rows_hash =
      parsed_grid
      |> Enum.map(&get_row_hash/1)

    col_res = cols_hash
    |> Enum.zip(1..length(cols_hash))
    |> get_potential_palindromes(cols_hash)

    row_res = rows_hash
    |> Enum.zip(1..length(rows_hash))
    |> get_potential_palindromes(rows_hash)

    col_res + row_res * 100
  end

  def solve do
    get_file()
    |> Enum.map(&get_score/1)
    |> Enum.sum()
  end
end
