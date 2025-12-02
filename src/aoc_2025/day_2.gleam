import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

// Parse a range from a string. Fails when given more or less data than expected.
// Gives string back as error.
fn parse_range(input: String) -> Result(#(Int, Int), String) {
  let candidate: Result(List(Int), Nil) =
    string.split(input, on: "-")
    |> list.try_map(with: fn(i) {
      case int.parse(i) {
        Ok(valid) -> Ok(valid)
        Error(invalid) -> Error(invalid)
      }
    })

  case candidate {
    Ok([start, end]) -> Ok(#(start, end))
    _ -> Error(input)
  }
}

pub fn parse(input: String) -> Result(List(#(Int, Int)), String) {
  // the input is a single line, so we only need to break down the string
  // it's formatted like: 11-22,95-115...
  // so we can split on commas, then parse the split strings into a pair of ints
  string.split(input, on: ",")
  |> list.try_map(with: fn(range) {
    case parse_range(range) {
      Ok(r) -> Ok(r)
      Error(e) -> Error(e)
    }
  })
}

pub fn is_invalid_pair(id: Int) -> Bool {
  // the problem description says:
  //   you can find the invalid IDs by looking for any ID which is made only of
  //   some sequence of digits repeated twice. So, 55 (5 twice), 6464 (64 twice),
  //    and 123123 (123 twice) would all be invalid IDs.
  //
  // from this description, i think we can establish:
  //   - no odd ID can be invalid
  //   - we only care about digit sequences which are the length of half the digits
  //
  // so the implementation is pretty simple:
  //   - convert int to a string
  //   - slice it in half
  //   - if the two halves are identical, it's invalid
  let id_string = int.to_string(id)
  let id_length = string.length(id_string)

  case string.length(id_string) % 2 {
    // odd lengths are never invalid
    n if n != 0 -> False

    _ -> {
      let halflength = id_length / 2
      let first = string.slice(from: id_string, at_index: 0, length: halflength)
      let second =
        string.slice(from: id_string, at_index: halflength, length: halflength)
      case first == second {
        False -> False
        True -> True
      }
    }
  }
  // ok wait -- can't we make a mathematical comparison to avoid string comparisons?
  // let's take the invalid example 212_212
  // if we separate the 10^1 -> 10^(n/2) digits from the rest, we get:
  //   212000 , 212
  //
  // if we then divide the 10^(n/2) -> 10^n digits by 10^n/2:
  //   212, 212
  //
  // and then can efficiently compare numbers to numbers
  //
  // lets try that approach once i know if my logic is sound ig
}

pub fn invalid_ids(in range: #(Int, Int), checker fun) -> List(Int) {
  list.range(pair.first(range), pair.second(range))
  |> list.filter(keeping: fn(id) { fun(id) })
}

pub fn pt_1(input: Result(List(#(Int, Int)), String)) -> Int {
  case input {
    Error(bad_parse) -> panic as { "bad range: " <> bad_parse }
    Ok(ranges) -> {
      list.map(ranges, with: fn(range) -> List(Int) {
        invalid_ids(in: range, checker: is_invalid_pair)
      })
      |> list.flatten()
      |> int.sum()
    }
  }
}

pub fn is_invalid_all(id: Int) -> Bool {
  todo as "is_invalid_all not implemented"
}

pub fn pt_2(input: Result(List(#(Int, Int)), String)) -> Int {
  // part 2 is a bit different -- instead of just halving, it's any
  // set of repeating digits from 1 digit to n/2 digits (or the string bisected)
  // so now the logic looks like:
  //   - check if string is all the same digit
  //   - if so, it's invalid
  //   - otherwise, if the string is even:
  //     - for each substring window set of sizes 2 -> n/2
  //     - check if every member of the set is identical 
  //       - if so, its invalid
  //       - otherwise, it's invalid
  //
  // we will need to consider short circuiting. i'm thinking recursive?
  case input {
    Error(bad_parse) -> panic as { "bad range: " <> bad_parse }
    Ok(ranges) -> {
      list.map(ranges, with: fn(range) -> List(Int) {
        invalid_ids(in: range, checker: is_invalid_all)
      })
      |> list.flatten()
      |> int.sum()
    }
  }
}
