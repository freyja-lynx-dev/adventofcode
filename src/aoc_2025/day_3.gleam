import gleam/int
import gleam/list.{Continue, Stop}
import gleam/pair
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
  list.map(input, with: fn(bank: List(Int)) -> Int {
    // our previous mistake was that we were assuming you would take the
    // two highest single voltage cells at any point
    //
    // turns out, it's actually the highest pair of digits, so long as
    // they are sequential:
    //   8_1_8_1_8_1_9_1_1_1_1_2_1_1_1 -> 9 2 -> 92
    //   not ... -> 8 9 -> 89
    //
    // there is probably a way to do this as a single pass
    // but for now, we could implement this over two folds:
    //   - one fold to get the biggest tens place digit
    //   - one fold to maximize from thereon
    //
    // since we have the example 811..9 -> 89, i dont' think we need to
    // worry about ordering yet, but it is trivial to preserve the indexing anyways
    // so we can just do two index folds and probably get the right answer
    //
    // who knows, maybe pt2 involves the indices lol
    let bank_last = list.length(bank) - 1
    let #(index, tens): #(Int, Int) =
      list.index_fold(over: bank, from: #(-1, -1), with: fn(acc, cell, index) {
        let #(_, highest_joltage) = acc
        case cell {
          // we can disregard the last digit, as it will not have any pairing
          // after itself
          _ if index == bank_last -> acc
          // new highest joltage
          newjoltage if cell > highest_joltage -> #(index, newjoltage)
          // we want the earliest instance of the highest joltage
          _ -> acc
        }
      })
    let ones: Int =
      list.split(bank, index + 1)
      |> pair.second
      |> list.fold_until(from: -1, with: fn(highest, cell) {
        // echo highest
        case cell > highest {
          _ if highest == 9 -> Stop(highest)
          True -> Continue(cell)
          False -> Continue(highest)
        }
      })
    int.multiply(tens, 10)
    |> int.add(ones)
  })
  |> int.sum
}

pub fn pt_2(input: List(List(Int))) -> Int {
  todo as "part 2 not implemented"
}
