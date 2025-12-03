import gleam/int
import gleam/list
import gleam/pair
import gleam/set.{type Set}
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
      let invalid_ids = pt_1_all_invalid_ids()
      list.map(ranges, with: fn(range) {
        let #(lower, upper) = range
        list.filter(list.range(lower, upper), keeping: fn(id) {
          set.contains(invalid_ids, id)
        })
      })
      |> list.flatten()
      |> int.sum()
    }
  }
}

fn is_invalid_all_helper(
  id id: List(String),
  length length: Int,
  chunk_by chunk_by: Int,
) -> Bool {
  case
    chunk_by > { length / 2 },
    list.unique(list.sized_chunk(in: id, into: chunk_by))
  {
    // if we haven't yet found invalidity, it is not possible once
    // we are above n/2 chunks
    True, _ -> False
    // if we only get one unique chunk, it is invalid
    _, [_] -> True
    // base case
    _, _ -> is_invalid_all_helper(id, length, chunk_by + 1)
  }
}

pub fn is_invalid_all(id: Int) -> Bool {
  let id_string = int.to_string(id)
  let id_length = string.length(id_string)
  let id_graphemes = string.to_graphemes(id_string)
  case id_length {
    1 -> False
    _ -> is_invalid_all_helper(id_graphemes, id_length, 1)
  }
}

fn generate_repeats(n, str) -> Int {
  case
    {
      list.repeat(str, n)
      |> string.concat
      |> int.parse
    }
  {
    Error(_) ->
      panic as "we're converting from ints, it should always work. in generate_repeats"
    Ok(n) -> n
  }
}

fn invalid_ids_from(num: Int) -> List(Int) {
  let num_as_str = int.to_string(num)
  let max_repeat = 10 / string.length(num_as_str)

  list.range(2, max_repeat)
  |> list.map(fn(x) { generate_repeats(x, num_as_str) })
}

fn pt_1_all_invalid_ids() -> Set(Int) {
  list.range(1, 99_999)
  |> list.map(with: fn(n) {
    let substr = int.to_string(n)
    case int.parse(substr <> substr) {
      Error(_) -> panic as "should never happen in all_invalid_ids"
      Ok(invalid_id) -> invalid_id
    }
  })
  |> set.from_list()
}

fn pt_2_all_invalid_ids() -> Set(Int) {
  // so we have ids lengths 1 -> 10
  // we can thus generate all invalid ids
  // and then check every potential invalid ID for the set of invalid ids
  // this generates all invalid ids for the pair case
  //
  // this currently only generates the pt_1 case, where the ids are
  // bisected by repeating digits
  //
  // how do we get the rest?
  list.range(1, 99_999)
  |> list.map(with: fn(n) { invalid_ids_from(n) })
  |> list.flatten
  |> set.from_list()
}

pub fn pt_2(input: Result(List(#(Int, Int)), String)) -> Int {
  // part 2 is a bit different -- instead of just halving, it's any
  // set of repeating digits from 1 digit to n/2 digits (or the string bisected)
  // so now the logic looks like:
  //   - check if string is all the same digit
  //   - if so, it's invalid
  //   - otherwise, for each substring window set of sizes 2 -> n/2
  //     - check if every member of the set is identical 
  //       - if so, its invalid
  //       - otherwise, it's invalid
  //
  // we will need to consider short circuiting. i'm thinking recursive?
  case input {
    Error(bad_parse) -> panic as { "bad range: " <> bad_parse }
    Ok(ranges) -> {
      let invalid_ids = pt_2_all_invalid_ids()
      list.map(ranges, with: fn(range) {
        let #(lower, upper) = range
        list.filter(list.range(lower, upper), keeping: fn(id) {
          set.contains(invalid_ids, id)
        })
      })
      |> list.flatten()
      |> int.sum()
    }
  }
}
