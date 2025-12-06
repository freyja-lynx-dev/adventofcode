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
  let directions = [
    // left
    #(-1, 0),
    // right
    #(1, 0),
    // down
    #(0, -1),
    // up
    #(0, 1),
    // leftup
    #(-1, 1),
    // rightup
    #(1, 1),
    // rightdown 
    #(1, -1),
    // leftdown
    #(-1, -1),
  ]
  set.fold(over: input, from: 0, with: fn(acc, point) {
    case is_accessible(point:, from: directions, on: input, max: 3) {
      False -> acc
      True -> acc + 1
    }
  })
}

fn do_pick_rolls(grid, directions, sum) {
  set.fold(over: grid, from: #(list.new(), grid, sum), with: fn(acc, point) {
    let #(accessible, grid, picks) = acc
    case is_accessible(point:, from: directions, on: grid, max: 3) {
      False -> acc
      True -> {
        // take accessible rolls greedily
        #([point, ..accessible], set.delete(from: grid, this: point), picks + 1)
      }
    }
  })
}

fn pick_rolls_helper(
  in grid: Set(#(Int, Int)),
  by directions: List(#(Int, Int)),
  sum sum: Int,
) -> Int {
  case do_pick_rolls(grid, directions, sum) {
    #([], _, total) -> total
    #(_, new_grid, acc) -> {
      pick_rolls_helper(in: new_grid, by: directions, sum: acc)
    }
  }
}

fn pick_rolls(
  in grid: Set(#(Int, Int)),
  by directions: List(#(Int, Int)),
) -> Int {
  pick_rolls_helper(in: grid, by: directions, sum: 0)
}

pub fn pt_2(input: Set(#(Int, Int))) {
  let directions = [
    // left
    #(-1, 0),
    // right
    #(1, 0),
    // down
    #(0, -1),
    // up
    #(0, 1),
    // leftup
    #(-1, 1),
    // rightup
    #(1, 1),
    // rightdown 
    #(1, -1),
    // leftdown
    #(-1, -1),
  ]
  pick_rolls(in: input, by: directions)
}
