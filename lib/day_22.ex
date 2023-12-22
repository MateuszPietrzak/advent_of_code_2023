defmodule AdventOfCode2023.Day22.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day22.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end

  def replace_range(list, b, e, v) do
    Enum.zip(list, 0..(length(list) - 1))
    |> Enum.map(fn {k, i} -> if i >= b and i <= e, do: v, else: k end)
  end

  def fall_bricks([], _highest_points, touching_map), do: touching_map

  def fall_bricks([{[x1, y1, z1, x2, y2, z2], index} | cubes_tail], highest_points, touching_map) do
    subrange =
      Enum.slice(highest_points, y1..y2)
      |> Enum.map(&Enum.slice(&1, x1..x2))
      |> List.flatten()

    target_height =
      subrange
      |> Enum.map(fn {v, _} -> v end)
      |> Enum.max()

    unique_depends =
      subrange
      |> Enum.filter(fn {k, _} -> k == target_height end)
      |> Enum.map(fn {_, o} -> o end)
      |> Enum.uniq()
      |> Enum.filter(fn x -> x != :none end)
      |> Enum.map(fn x -> {index, x} end)

    cube_height = z2 - z1 + 1 + target_height

    new_highest_points =
      Enum.zip(highest_points, 0..(length(highest_points) - 1))
      |> Enum.map(fn {k, i} ->
        if i >= y1 and i <= y2, do: replace_range(k, x1, x2, {cube_height, index}), else: k
      end)

    new_highest_points
    |> Enum.map(&Enum.map(&1, fn {a, _} -> a end))

    new_touching_map = touching_map ++ unique_depends

    fall_bricks(cubes_tail, new_highest_points, new_touching_map)
  end

  def get_dependencies(file) do
    cubes =
      file
      |> Enum.map(&String.split(&1, [",", "~"], trim: true))
      |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
      |> Enum.sort(fn [_, _, z1, _, _, z2], [_, _, z3, _, _, z4] ->
        if z1 == z3, do: z2 < z4, else: z1 < z3
      end)

    highest_points = List.duplicate(List.duplicate({0, :none}, 10), 10)

    fall_bricks(Enum.zip(cubes, 1..length(cubes)), highest_points, [])
    |> Enum.reduce(%{}, fn {top, bottom}, acc ->
      if Map.get(acc, top) == nil,
        do: Map.put(acc, top, [bottom]),
        else: Map.put(acc, top, [bottom | Map.get(acc, top)])
    end)
  end
end

defmodule AdventOfCode2023.Day22.Part1 do
  import AdventOfCode2023.Day22.Utility

  def solve do
    file = get_file()

    result =
      get_dependencies(file)
      |> Enum.to_list()
      |> Enum.map(fn {_, v} -> v end)

    r =
      Enum.filter(result, fn x -> length(x) == 1 end)
      |> List.flatten()
      |> Enum.uniq()

    (Enum.into(1..length(file), []) -- r)
    |> length()
  end
end

defmodule AdventOfCode2023.Day22.Part2 do
  import AdventOfCode2023.Day22.Utility

  def cascade_down(up, queue, visited) do
    if :queue.is_empty(queue) do
      0
    else
      {{:value, key}, new_queue} = :queue.out(queue)
      if Map.get(visited, key) != nil do
        cascade_down(up, new_queue, visited) 
      else 
        # IO.inspect(key, label: "in")
        reject_self = Enum.reject(up, fn {k, _} -> k == key end)
        new_up = Enum.map(reject_self, fn {k, v} -> {k, Enum.reject(v, &(&1==key))} end)# |> IO.inspect(label: "new up")
        next_queue = Enum.reduce(new_up, new_queue, fn {k, v}, acc -> if length(v) == 0, do: :queue.in(k, acc), else: acc end)
        1 + cascade_down(new_up, next_queue, Map.put(visited, key, true))
      end
    end
  end

  def count_falling(index, up) do
    reject_self = Enum.reject(up, fn {k, _} -> k == index end)
    new_up = Enum.map(reject_self, fn {k, v} -> {k, Enum.reject(v, &(&1==index))} end)# |> IO.inspect(label: "new up")
    # score_add = Enum.count(new_up, fn {_, v} -> length(v) == 0 end)
    queue = Enum.reduce(new_up, :queue.new(), fn {k, v}, acc -> if length(v) == 0, do: :queue.in(k, acc), else: acc end)
    cascade_down(new_up, queue, %{}) 
  end

  def solve do
    file = get_file()
    r = get_dependencies(file)

    up =
      Enum.reduce(1..length(file), %{}, fn x, acc ->
        if Map.get(r, x) == nil do
          Map.put(acc, x, [0])
        else
          Map.put(acc, x, Map.get(r, x))
        end
      end)
      |> Enum.to_list()

    Enum.map(1..length(file), &count_falling(&1, up))
    |> Enum.sum()
  end
end
