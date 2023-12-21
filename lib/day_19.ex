defmodule AdventOfCode2023.Day19.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day19.in")

    IO.read(file, :eof)
    |> String.split("\n\n", trim: true)
  end

  def process_workflow(line) do
    [name | conditions] =
      line
      |> String.split(["{", ",", "}"], trim: true)

    {String.to_atom(name),
     Enum.map(conditions, fn x ->
       cond do
         x == "R" ->
           :R

         x == "A" ->
           :A

         Enum.any?(String.to_charlist(x), fn char -> char == ?> end) ->
           with [category, amount, next_workflow] <- String.split(x, [">", ":"], trim: true) do
             {:greater_than, String.to_atom(category), String.to_integer(amount),
              String.to_atom(next_workflow)}
           end

         Enum.any?(String.to_charlist(x), fn char -> char == ?< end) ->
           with [category, amount, next_workflow] <- String.split(x, ["<", ":"], trim: true) do
             {:less_than, String.to_atom(category), String.to_integer(amount),
              String.to_atom(next_workflow)}
           end

         true ->
           String.to_atom(x)
       end
     end)}
  end

  def process_rating(line) do
    line
    |> String.split(["{", ",", "}"], trim: true)
    |> Enum.map(fn x -> String.split(x, "=", trim: true) end)
    |> Enum.map(fn [category, score] -> {String.to_atom(category), String.to_integer(score)} end)
  end
end

defmodule AdventOfCode2023.Day19.Part1 do
  import AdventOfCode2023.Day19.Utility

  def accepted?(part, [{:less_than, category, amount, next_key} | entry_tail], map) do
    if part[category] < amount do
      case next_key do
        :A -> true
        :R -> false
        _ -> accepted?(part, Map.get(map, next_key), map)
      end
    else
      accepted?(part, entry_tail, map)
    end
  end

  def accepted?(part, [{:greater_than, category, amount, next_key} | entry_tail], map) do
    if part[category] > amount do
      case next_key do
        :A -> true
        :R -> false
        _ -> accepted?(part, Map.get(map, next_key), map)
      end
    else
      accepted?(part, entry_tail, map)
    end
  end

  def accepted?(part, [action | _], map) do
    case action do
      :A -> true
      :R -> false
      _ -> accepted?(part, Map.get(map, action), map)
    end
  end

  def solve do
    [workflows_string, ratings_string] = get_file()

    workflows =
      workflows_string
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn x, acc ->
        with {key, value} <- process_workflow(x) do
          Map.put(acc, key, value)
        end
      end)

    ratings_string
    |> String.split("\n", trim: true)
    |> Enum.map(&process_rating/1)
    |> Enum.map(fn rat ->
      if accepted?(rat, Map.get(workflows, :in), workflows) do
        rat[:x] + rat[:m] + rat[:a] + rat[:s]
      else
        0
      end
    end)
    |> Enum.sum()
  end
end

defmodule AdventOfCode2023.Day19.Part2 do
  import AdventOfCode2023.Day19.Utility

  def accepted?([x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, se}] = interval, _, _)
      when xe < xb or me < mb or ae < ab or se < sb do
    IO.inspect(interval, label: "degenerated")
    []
  end

  def accepted?(
        [x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, se}],
        [{:less_than, category, amount, next_key} | entry_tail],
        map
      ) do
    case category do
      :x ->
        accepted?(
          [x: {xb, amount - 1}, m: {mb, me}, a: {ab, ae}, s: {sb, se}],
          Map.get(map, next_key),
          map
        ) ++
          accepted?([x: {amount, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, se}], entry_tail, map)

      :m ->
        accepted?(
          [x: {xb, xe}, m: {mb, amount - 1}, a: {ab, ae}, s: {sb, se}],
          Map.get(map, next_key),
          map
        ) ++
          accepted?([x: {xb, xe}, m: {amount, me}, a: {ab, ae}, s: {sb, se}], entry_tail, map)

      :a ->
        accepted?(
          [x: {xb, xe}, m: {mb, me}, a: {ab, amount - 1}, s: {sb, se}],
          Map.get(map, next_key),
          map
        ) ++
          accepted?([x: {xb, xe}, m: {mb, me}, a: {amount, ae}, s: {sb, se}], entry_tail, map)

      :s ->
        accepted?(
          [x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, amount - 1}],
          Map.get(map, next_key),
          map
        ) ++
          accepted?([x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {amount, se}], entry_tail, map)
    end
  end

  def accepted?(
        [x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, se}],
        [{:greater_than, category, amount, next_key} | entry_tail],
        map
      ) do
    case category do
      :x ->
        accepted?(
          [x: {xb, amount}, m: {mb, me}, a: {ab, ae}, s: {sb, se}],
          entry_tail,
          map
        ) ++
          accepted?(
            [x: {amount + 1, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, se}],
            Map.get(map, next_key),
            map
          )

      :m ->
        accepted?(
          [x: {xb, xe}, m: {mb, amount}, a: {ab, ae}, s: {sb, se}],
          entry_tail,
          map
        ) ++
          accepted?(
            [x: {xb, xe}, m: {amount + 1, me}, a: {ab, ae}, s: {sb, se}],
            Map.get(map, next_key),
            map
          )

      :a ->
        accepted?(
          [x: {xb, xe}, m: {mb, me}, a: {ab, amount}, s: {sb, se}],
          entry_tail,
          map
        ) ++
          accepted?(
            [x: {xb, xe}, m: {mb, me}, a: {amount + 1, ae}, s: {sb, se}],
            Map.get(map, next_key),
            map
          )

      :s ->
        accepted?(
          [x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, amount}],
          entry_tail,
          map
        ) ++
          accepted?(
            [x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {amount + 1, se}],
            Map.get(map, next_key),
            map
          )
    end
  end

  def accepted?(interval, [action | _], map) do
    case action do
      :A -> [interval]
      :R -> []
      _ -> accepted?(interval, Map.get(map, action), map)
    end
  end

  def solve do
    [workflows_string, _] = get_file()

    workflows =
      workflows_string
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn x, acc ->
        with {key, value} <- process_workflow(x) do
          Map.put(acc, key, value)
        end
      end)

    accepted?(
      [x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}],
      Map.get(workflows, :in),
      Map.merge(workflows, %{A: [:A], R: [:R]})
    )
    |> Enum.map(fn [x: {xb, xe}, m: {mb, me}, a: {ab, ae}, s: {sb, se}] ->
      (xe - xb + 1) * (me - mb + 1) * (ae - ab + 1) * (se - sb + 1)
    end)
    |> Enum.sum()
  end
end
