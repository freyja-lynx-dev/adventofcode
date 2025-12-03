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
  list.map(input, with: fn(bank: List(Int)) -> Int {
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

pub fn int_power(base base: Int, power power: Int) -> Int {
  // this is kinda dumb but it works
  case power {
    0 -> 1
    1 -> base
    2 -> base * base
    3 -> base * base * base
    _ ->
      list.repeat(base, power - 1)
      |> list.fold(from: base, with: int.multiply)
  }
}

// let say we need 12 cells (m), from banks of n=15:
//   - we only need to search indicies 0-(n-12) (0,1,2,3), as we need at least 11 following cells
//   - with the maximal digit and its index, we slice the bank after that digit,
//     then search for the 10^(m-1) digit, over the cells which leave 10 following cells 
//     - in our case: 10^11th digit, from i:3 to i:4 inclusive
//     - 10^(m-i), (0 -> n-m-i)
//     - the general math:
//       let n be the size of the battery bank
//       let m be the number of cells we want from the battery bank
//       let i be the current digit, in sequential numbering order (1,2.. n)
//       let j be the previous digit's index, initialized to 0
//       let d be a list of digits that will be concatenated for the final number
//   
//       for i in range(1,m):
//         search(in: bank_slice(after:j), from: 0, to: n-m-i)
//       then:
//         concatenate_digits(d)
//           for i in range(length(d), 0):
//             d[i] *= pow(10,i)
fn find_maximal_joltage(in bank: List(Int), take m: Int, seed sum: Int) -> Int {
  let n = list.length(bank)
  case m {
    // if we run out of digits to take, we're at the max
    0 -> sum
    // if we need the same amount of cells we have in the bank, that's the max
    m if m == n -> {
      list.index_map(bank, with: fn(digit, index) {
        digit * int_power(10, n - index - 1)
      })
      |> int.sum
      |> int.add(sum)
    }
    _ -> {
      // establish search range
      let #(possible, _) = list.split(bank, n - m + 1)
      let window = list.range(from: 0, to: n - m)

      let possible = case list.strict_zip(window, possible) {
        Ok(possible) -> possible
        _ -> panic as "should never have incompatible lists"
      }
      // search the range for the maximal digit
      let #(findex, fjoltage) =
        list.fold_until(over: possible, from: #(-1, -1), with: fn(highest, x) {
          let #(_, joltage) = x
          let #(_, hjoltage) = highest
          case joltage {
            joltage if joltage == 9 -> Stop(x)
            joltage if joltage > hjoltage -> Continue(x)
            _ -> Continue(highest)
          }
        })
      // scale it to the proper power
      let scaled_joltage = int.multiply(fjoltage, int_power(10, m - 1))
      // add to the result of searching the rest of the bank
      let #(_, next_bank) = list.split(bank, findex + 1)

      find_maximal_joltage(
        in: next_bank,
        take: m - 1,
        seed: sum + scaled_joltage,
      )
    }
  }
}

pub fn pt_2(input: List(List(Int))) -> Int {
  // ok so we basically need to generalize the algorithm in pt1:
  // we need a sequential, but not necessarily contiguous, set of N cells from
  // the battery bank, to maximize the number of jolts
  //
  list.map(input, with: fn(bank: List(Int)) -> Int {
    find_maximal_joltage(in: bank, take: 12, seed: 0)
  })
  |> int.sum
}
