defmodule AdventOfCode2023.Day3.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day3.in")
    IO.read(file, :eof)
  end
end

defmodule AdventOfCode2023.Day3.Part1 do
  import AdventOfCode2023.Day3.Utility

  def is_symbol?(file, index) do
    if index >= 0 do
      char = Enum.at(file, index, ?.)
      char != ?. and char != ?\n and (char < ?0 or char > ?9)
    else
      false
    end
  end

  def check_symbols(file, index, line_length) do
    cond do
      is_symbol?(file, index-line_length-1) -> true
      is_symbol?(file, index-line_length) -> true
      is_symbol?(file, index-line_length+1) -> true
      is_symbol?(file, index-1) -> true
      is_symbol?(file, index+1) -> true
      is_symbol?(file, index+line_length-1) -> true
      is_symbol?(file, index+line_length) -> true
      is_symbol?(file, index+line_length+1) -> true
      true -> false
    end
  end

  def check_number(file, number_index, line_length) do
    number_end = 
      file
      |> Enum.drop(number_index)
      |> Enum.find_index(fn x -> x < ?0 or x > ?9 end)

    number =
      file
      |> Enum.slice(number_index, number_end)
      |> List.to_string()
      |> String.to_integer()

    next_number_beginning =
      file
      |> Enum.slice(number_index+number_end, length(file))
      |> Enum.find_index(fn x -> x >= ?0 and x <= ?9 end)
    
    if next_number_beginning == nil do
      if Enum.any?(
        number_index..number_index+number_end-1, 
        &check_symbols(file, &1, line_length)) do
        number
      else
        0
      end
    else
      if Enum.any?(
        number_index..number_index+number_end-1, 
        &check_symbols(file, &1, line_length)) do
        number + check_number(file, next_number_beginning + number_index + number_end, line_length)
      else
        0 + check_number(file, next_number_beginning + number_index + number_end, line_length)
      end
    end
  end

  def solve do
    file = get_file()
    |> String.to_charlist()

    line_length = 
      file
      |> Enum.find_index(fn x -> x == ?\n end)

    line_length = line_length + 1 

    first_number =
      file
      |> Enum.find_index(fn x -> x >= ?0 and x <= ?9 end)

    check_number(file, first_number, line_length)
  end
end


defmodule AdventOfCode2023.Day3.Part2 do
  import AdventOfCode2023.Day3.Utility

  def find_stars([], _), do: []

  def find_stars([head | tail], index) do
    if(head == ?*) do
      [index | find_stars(tail, index + 1)]
    else
      find_stars(tail, index + 1)
    end
  end

  def is_digit?(char) do
    char >= ?0 and char <= ?9
  end

  def generate_numbers_table([], _), do: []
  def generate_numbers_table([head | tail] = list, last_found_number) do
    if is_digit?(head) do
      if last_found_number == :no_number do
        num = list 
        |> Enum.slice(0..Enum.find_index(list, fn x -> not is_digit?(x) end) - 1) 
        |> List.to_string() 
        |> String.to_integer()
        [num | generate_numbers_table(tail, num)]
      else
        [last_found_number | generate_numbers_table(tail, last_found_number)]
      end
    else
      [:no_number | generate_numbers_table(tail, :no_number)]
    end
  end

  def check_star(index, line_length, numbers_table) do
    up_left = if index-line_length-1 >= 0 and Enum.at(numbers_table, index-line_length-1, :no_number) != :no_number, do: [Enum.at(numbers_table, index-line_length-1)], else: []
    up = if up_left == [] and index-line_length >= 0 and Enum.at(numbers_table, index-line_length, :no_number) != :no_number, do: [Enum.at(numbers_table, index-line_length)], else: []
    up_right = if index-line_length+1 >= 0 and Enum.at(numbers_table, index-line_length, :no_number) == :no_number and Enum.at(numbers_table, index-line_length+1, :no_number) != :no_number, do: [Enum.at(numbers_table, index-line_length+1)], else: []

    left = if index-1 >= 0 and Enum.at(numbers_table, index-1, :no_number) != :no_number, do: [Enum.at(numbers_table, index-1)], else: []
    right = if index+1 >= 0 and Enum.at(numbers_table, index+1, :no_number) != :no_number, do: [Enum.at(numbers_table, index+1)], else: []

    down_left = if Enum.at(numbers_table, index+line_length-1, :no_number) != :no_number, do: [Enum.at(numbers_table, index+line_length-1)], else: []
    down = if down_left == [] and Enum.at(numbers_table, index+line_length, :no_number) != :no_number, do: [Enum.at(numbers_table, index+line_length)], else: []
    down_right = if index+line_length+1 >= 0 and Enum.at(numbers_table, index+line_length, :no_number) == :no_number and Enum.at(numbers_table, index+line_length+1, :no_number) != :no_number, do: [Enum.at(numbers_table, index+line_length+1)], else: []

    adjacent = up_left ++ up ++ up_right ++ left ++ right ++ down_left ++ down ++ down_right

    if length(adjacent) == 2 do
      [a, b] = adjacent
      a * b
    else
      0
    end

  end

  def solve do
    file = get_file()
    |> String.to_charlist()

    line_length = 
      file
      |> Enum.find_index(fn x -> x == ?\n end)
      |> Kernel.+(1)

    numbers_table = generate_numbers_table(file, :no_number)

    file
    |> find_stars(0)
    |> Enum.map(&check_star(&1, line_length, numbers_table)) 
    |> Enum.sum()
  end
end
