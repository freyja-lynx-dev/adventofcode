import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(with: fn(bank) {
    string.to_graphemes(bank)
    |> list.map(fn(cell) {
      let assert Ok(joltage) = int.parse(cell)
      joltage
    })
  })
}

pub fn pt_1(input: List(List(Int))) -> Int {
  // i'm thinking we fold over each bank with a #(Int,Int)
  // and basically just collect the largest cells
  // ordering does matter, so maybe #(#(),#())
  list.map(input, with: fn(bank) {
    list.index_fold(
      over: bank,
      from: #(#(-1, -1), #(-1, -1)),
      with: fn(acc, cell, index) {
        // check if cell has higher joltage than the second element of the pair
        // if so, bump the second pair to the first slot, then fill the second with the current cell
        // otherwise, check if the cell has higher joltage than the first element
        // if so, replace the first pair with the cell
        // otherwise, return the original accumulator
        let #(#(findex, fjoltage), #(sindex, sjoltage)) = acc

        // we're getting 17290 on first try and that's too high
        // we're hitting some edge case i'm not sure of
        // i think we may need to make our case statement more complicated

        echo acc

        case index, cell {
          newindex, newjoltage if newjoltage > sjoltage && newindex > sindex -> #(
            #(sindex, sjoltage),
            #(newindex, newjoltage),
          )
          newindex, newjoltage if newjoltage > fjoltage && newindex > findex -> #(
            #(newindex, newjoltage),
            #(sindex, sjoltage),
          )
          _, _ -> acc
        }
      },
    )
  })
  |> list.map(with: fn(x) {
    let #(#(_, fjoltage), #(_, sjoltage)) = x

    case int.parse(int.to_string(sjoltage) <> int.to_string(fjoltage)) {
      Error(_) -> panic as "we're going from int to string to int, pt_1"
      Ok(joltage) -> joltage
    }
  })
  |> int.sum
}

pub fn pt_2(input: List(List(Int))) -> Int {
  todo as "part 2 not implemented"
}
