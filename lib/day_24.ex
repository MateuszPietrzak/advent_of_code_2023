defmodule AdventOfCode2023.Day24.Utility do
  def get_file do
    {:ok, file} = File.open("assets/day24.in")

    IO.read(file, :eof)
    |> String.split("\n", trim: true)
  end
end

defmodule AdventOfCode2023.Day24.Part1 do
  import AdventOfCode2023.Day24.Utility

  def solve do
    file =
      get_file()
      |> Enum.map(&String.split(&1, [", ", " @ "], trim: true))
      |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)

    low = 200_000_000_000_000
    high = 400_000_000_000_000

    for [x1, y1, z1, vx1, vy1, vz1] <- file,
        [x3, y3, z3, vx2, vy2, vz2] <- file,
        x1 != x3 or y1 != y3 or z1 != z3 or vx1 != vx2 or vy1 != vy2 or vz1 != vz2 do
      x2 = x1 + vx1
      y2 = y1 + vy1
      x4 = x3 + vx2
      y4 = y3 + vy2

      ixn = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)
      ixd = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

      iyn = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)
      iyd = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

      if ixd == 0 or iyd == 0 do
        :none
      else
        ix = ixn / ixd
        iy = iyn / iyd

        cond do
          ix < low or ix > high or iy < low or iy > high -> :none
          (ix < x1 and vx1 > 0) or (ix > x1 and vx1 < 0) -> :none
          (ix < x3 and vx2 > 0) or (ix > x3 and vx2 < 0) -> :none
          (iy < y1 and vy1 > 0) or (iy > y1 and vy1 < 0) -> :none
          (iy < y3 and vy2 > 0) or (iy > y3 and vy2 < 0) -> :none
          true -> {:correct, ix, iy, x1, y1, x3, y3}
        end
      end
    end
    |> Enum.filter(fn x -> x != :none end)
    |> length()
    |> div(2)
  end
end

defmodule AdventOfCode2023.Day24.Part2 do
  import AdventOfCode2023.Day24.Utility

  def solve_2_equations(a, b, c, d, e, f) do
    w = a * e - b * d
    wx = c * e - b * f
    wy = a * f - c * d

    if w == 0 do
      :none
    else
      {wx / w, wy / w}
    end
  end

  def intersection(a1, a2, a3, b1, b2, b3, c1, c2, c3, d1, d2, d3) do
    with {t1, _} <- solve_2_equations(b1, -d1, c1 - a1, b2, -d2, c2 - a2),
         {t2, _} <- solve_2_equations(b1, -d1, c1 - a1, b3, -d3, c3 - a3) do
      if abs(t1 - t2) < 0.0001 do
        {a1 + b1 * t1, a2 + b2 * t1, a3 + b3 * t1}
      else
        :none
      end
    else
      _ ->
        :none
    end
  end

  def check(x1, y1, z1, vx1, vy1, vz1, x2, y2, z2, vx2, vy2, vz2, x3, y3, z3, vx3, vy3, vz3, vx, vy, vz) do
      with {xa, ya, za} <-
             intersection(
               x1,
               y1,
               z1,
               vx1 - vx,
               vy1 - vy,
               vz1 - vz,
               x2,
               y2,
               z2,
               vx2 - vx,
               vy2 - vy,
               vz2 - vz
             ),
           {xb, yb, zb} <-
             intersection(
               x1,
               y1,
               z1,
               vx1 - vx,
               vy1 - vy,
               vz1 - vz,
               x3,
               y3,
               z3,
               vx3 - vx,
               vy3 - vy,
               vz3 - vz
             ) do
        if xa == xb and ya == yb and za == zb do
          IO.inspect(xa + ya + za)
        end
      end
  end

  def solve do
    [
      [x1, y1, z1, vx1, vy1, vz1],
      [x2, y2, z2, vx2, vy2, vz2],
      [x3, y3, z3, vx3, vy3, vz3]
    ] =
      get_file()
      |> Enum.map(&String.split(&1, [", ", " @ "], trim: true))
      |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)
      |> Enum.take(3)

    range = 500
    for vx <- -range..range, vy <- -range..range, vz <- -range..range do
      check(x1, y1, z1, vx1, vy1, vz1, x2, y2, z2, vx2, vy2, vz2, x3, y3, z3, vx3, vy3, vz3, vx, vy, vz)
    end
    :ok
  end
end
