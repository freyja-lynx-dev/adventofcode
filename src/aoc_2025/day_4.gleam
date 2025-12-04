import gleam/dict.{type Dict}
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

pub fn pt_1(input: String) {
  // idk brute force is pretty easy check every cell for neighbors
  // there could be an optimization somewhere in the mist
  // we have a dict of coordinates to bools, which is very easy to separate
  // if we had a dict of only the paper cells, you cut out some unnecessary cell checks
  // each cell check in naive approach calls into the dict at least 4, at most 8 times
  // whatever
  todo as "part 1 not implemented"
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
