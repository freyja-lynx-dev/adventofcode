import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

fn is_roll(cell: String) -> Bool {
  case cell {
    "@" -> True
    _ -> False
  }
}

pub fn parse(input: String) -> Dict(#(Int, Int), Bool) {
  string.split(input, on: "\n")
  |> list.filter(fn(x) { x != "" })
  |> list.index_map(fn(row, row_i) {
    list.index_map(string.to_graphemes(row), fn(element, column_i) {
      #(#(column_i, row_i), is_roll(element))
    })
  })
  |> list.flatten
  |> dict.from_list
}

fn is_accessible(
  point point: #(Int, Int),
  from directions: List(#(Int, Int)),
  on grid: Dict(#(Int, Int), Bool),
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
      case dict.get(grid, d) {
        Error(_) -> acc
        Ok(roll) if !roll -> acc
        Ok(_) -> acc + 1
      }
    })

  neighbors <= max
}

pub fn pt_1(input: Dict(#(Int, Int), Bool)) -> Int {
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
  dict.fold(over: input, from: 0, with: fn(acc, point, value) {
    case value {
      False -> acc
      True -> {
        case is_accessible(point:, from: directions, on: input, max: 3) {
          False -> acc
          True -> acc + 1
        }
      }
    }
  })
}

pub fn pt_2(input: Dict(#(Int, Int), Bool)) {
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
  dict.fold(over: input, from: 0, with: fn(acc, point, value) {
    case value {
      False -> acc
      True -> {
        case is_accessible(point:, from: directions, on: input, max: 3) {
          False -> {
            // keep track of inaccessible rolls
            acc
          }
          True -> {
            // take accessible rolls greedily
            acc + 1
          }
        }
      }
    }
  })
}
