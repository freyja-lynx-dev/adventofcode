import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) -> Set(#(Int, Int)) {
  string.split(input, on: "\n")
  |> list.filter(fn(x) { x != "" })
  |> list.index_map(fn(row, y) {
    list.index_map(string.to_graphemes(row), fn(element, x) {
      case element {
        "@" -> #(x, y)
        _ -> #(-1, -1)
      }
    })
  })
  |> list.flatten
  |> list.filter(keeping: fn(x) { x != #(-1, -1) })
  |> set.from_list
}

fn is_accessible(
  point point: #(Int, Int),
  from directions: List(#(Int, Int)),
  on grid: Set(#(Int, Int)),
  max max: Int,
) -> Bool {
  let #(px, py) = point

  let points =
    list.map(directions, with: fn(d) {
      let #(dx, dy) = d
      #(px + dx, py + dy)
    })
  let neighbors =
    list.fold(over: points, from: 0, with: fn(acc, d) {
      case set.contains(grid, d) {
        False -> acc
        True -> acc + 1
      }
    })

  neighbors <= max
}

pub fn pt_1(input: Set(#(Int, Int))) -> Int {
  // idk brute force is pretty easy check every cell for neighbors
  // there could be an optimization somewhere in the mist
  // we have a dict of coordinates to bools, which is very easy to separate
  // if we had a dict of only the paper cells, you cut out some unnecessary cell checks
  // each cell check in naive approach calls into the dict at least 4, at most 8 times
  // whatever
  set.fold(over: input, from: 0, with: fn(acc, point) {
    case is_accessible2(input, point) {
      False -> acc
      True -> acc + 1
    }
  })
}

fn do_pick_rolls(
  grid: Set(#(Int, Int)),
  sum: Int,
) -> #(List(#(Int, Int)), Set(#(Int, Int)), Int) {
  set.fold(over: grid, from: #(list.new(), grid, sum), with: fn(acc, point) {
    let #(accessible, grid, picks) = acc
    case is_accessible2(grid, point) {
      False -> acc
      True -> {
        // take accessible rolls greedily
        #([point, ..accessible], set.delete(from: grid, this: point), picks + 1)
      }
    }
  })
}

fn pick_rolls(in grid: Set(#(Int, Int)), sum sum: Int) -> Int {
  case do_pick_rolls(grid, sum) {
    #([], _, total) -> total
    #(_, new_grid, acc) -> {
      pick_rolls(in: new_grid, sum: acc)
    }
  }
}

pub fn pt_2(input: Set(#(Int, Int))) {
  pick_rolls(in: input, sum: 0)
}

// the functions below are not mine, they're @LittleLily on discord, for study
fn neighbors(c: #(Int, Int)) -> List(#(Int, Int)) {
  let #(x, y) = c

  [
    #(x - 1, y - 1),
    #(x - 1, y + 1),
    #(x + 1, y - 1),
    #(x + 1, y + 1),
    #(x, y + 1),
    #(x, y - 1),
    #(x + 1, y),
    #(x - 1, y),
  ]
}

fn is_accessible2(rolls: Set(#(Int, Int)), p: #(Int, Int)) -> Bool {
  list.count(neighbors(p), set.contains(rolls, _)) < 4
}

fn flood_remove(acc: #(Set(#(Int, Int)), Int), c: #(Int, Int)) {
  case set.contains(acc.0, c) && is_accessible2(acc.0, c) {
    False -> acc
    True ->
      list.fold(neighbors(c), #(set.delete(acc.0, c), acc.1 + 1), flood_remove)
  }
}
