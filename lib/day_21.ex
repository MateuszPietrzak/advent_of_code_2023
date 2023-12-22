defmodule AdventOfCode2023.Day21.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day21.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def bfs(file, queue, max_depth) do
    if :queue.is_empty(queue) do
      file
    else
      {{:value, {row, col, depth}}, new_queue} = :queue.out(queue)

      if row < 0 or col < 0 or row >= length(file) or col >= length(hd(file)) or
           Enum.at(Enum.at(file, row, []), col, -2) != -1 or depth > max_depth do
        bfs(file, new_queue, max_depth)
      else
        # IO.inspect({row, col, depth})
        new_file =
          List.replace_at(file, row, List.replace_at(Enum.at(file, row), col, depth))

        neighbors =
          :queue.from_list([
            {row + 1, col, depth + 1},
            {row - 1, col, depth + 1},
            {row, col - 1, depth + 1},
            {row, col + 1, depth + 1}
          ])

        bfs(new_file, :queue.join(new_queue, neighbors), max_depth)
      end
    end
  end
end

defmodule AdventOfCode2023.Day21.Part1 do
  import AdventOfCode2023.Day21.Utility

  def find_beginning([head | tail], row) do
    if Enum.any?(head, fn x -> x == ?S end) do
      {row, Enum.find_index(head, fn x -> x == ?S end)}
    else
      find_beginning(tail, row + 1)
    end
  end

  def solve do
    file = get_file()

    queue = :queue.new()

    {row, col} = find_beginning(file, 0)

    res =
      bfs(
        file |> Enum.map(&Enum.map(&1, fn c -> if c in [?., ?S], do: -1, else: -2 end)),
        :queue.in({row, col, 0}, queue),
        64
      )

    Enum.map(
      res,
      &Enum.reduce(&1, 0, fn x, acc -> if x >= 0 and rem(x, 2) == 0, do: acc + 1, else: acc end)
    )
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day21.Part2 do
  import AdventOfCode2023.Day21.Utility

  def find_beginning([head | tail], row) do
    if Enum.any?(head, fn x -> x == ?S end) do
      {row, Enum.find_index(head, fn x -> x == ?S end)}
    else
      find_beginning(tail, row + 1)
    end
  end

  def get_score(file, row, col, max_depth, parity) do
    bfs(
      file |> Enum.map(&Enum.map(&1, fn c -> if c in [?., ?S], do: -1, else: -2 end)),
      :queue.in({row, col, 0}, :queue.new()),
      max_depth
    )
    |> Enum.map(
      &Enum.reduce(&1, 0, fn x, acc ->
        if x >= 0 and rem(x, 2) == if(parity == :even, do: 0, else: 1), do: acc + 1, else: acc
      end)
    )
    |> Enum.sum()
  end

  def solve do
    file = get_file()

    size = 130
    halfsize = div(size, 2)
    radius = 202_300
    infinity = 1_000_000_000

    odd_rhombus =
      get_score(file, halfsize, halfsize, infinity, :odd) * (radius - 1) * (radius - 1)

    even_rhombus =
      get_score(file, halfsize, halfsize, infinity, :even) * radius * radius

    top = get_score(file, size, halfsize, size, :even)
    right = get_score(file, halfsize, 0, size, :even)
    bottom = get_score(file, 0, halfsize, size, :even)
    left = get_score(file, halfsize, size, size, :even)

    top_right_big =
      get_score(file, size, 0, size + halfsize, :odd) * (radius - 1)

    bottom_right_big =
      get_score(file, 0, 0, size + halfsize, :odd) * (radius - 1)

    bottom_left_big =
      get_score(file, 0, size, size + halfsize, :odd) * (radius - 1)

    top_left_big =
      get_score(file, size, size, size + halfsize, :odd) * (radius - 1)

    top_right_small =
      get_score(file, size, 0, halfsize - 1, :even) * radius

    bottom_right_small =
      get_score(file, 0, 0, halfsize - 1, :even) * radius

    bottom_left_small =
      get_score(file, 0, size, halfsize - 1, :even) * radius

    top_left_small =
      get_score(file, size, size, halfsize - 1, :even) * radius

    even_rhombus + odd_rhombus + top + right + bottom + left + top_right_big + bottom_right_big +
      bottom_left_big + top_left_big + top_right_small + bottom_right_small + bottom_left_small +
      top_left_small
  end
end
