import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

// we get a series of rotation directions in the format $Direction$Clicks
// these rotations happen on a dial that goes from 0 to 99, and starts at 50
// we need to add up the mount of times that the dial points at 0
//
// the plan:
// create a type for an unsigned integer with settable max
// fold over the directions and add up the amount of times a rotation gets us 0

type UnsignedInt {
  UnsignedInt(n: Int, max: Int)
}

// adds 1 to an UnsignedInt, respecting its bounds
fn forward_tick(a: UnsignedInt) -> UnsignedInt {
  case a.n {
    x if x == a.max -> UnsignedInt(0, a.max)
    _ -> UnsignedInt(a.n + 1, a.max)
  }
}

// removes 1 from an UnsignedInt, respecting its bounds
fn backward_tick(a: UnsignedInt) -> UnsignedInt {
  case a.n {
    0 -> UnsignedInt(a.max, a.max)
    _ -> UnsignedInt(a.n - 1, a.max)
  }
}

// i don't think this benefits from tail call recursion 3:
fn rotate_helper(a: UnsignedInt, seed: #(Int, Int)) -> #(Int, Int) {
  let cur = a.n
  let rem = pair.second(seed)
  let zero_ticks = pair.first(seed)

  case cur, rem {
    // log an encountered 0 tick
    0, rem if rem > 0 -> {
      let new = forward_tick(a)
      rotate_helper(new, #(zero_ticks + 1, rem - 1))
    }
    0, rem if rem < 0 -> {
      let new = backward_tick(a)
      rotate_helper(new, #(zero_ticks + 1, rem + 1))
    }
    _, rem if rem > 0 -> {
      let new = forward_tick(a)
      rotate_helper(new, #(zero_ticks, rem - 1))
    }
    _, rem if rem < 0 -> {
      let new = backward_tick(a)
      rotate_helper(new, #(zero_ticks, rem + 1))
    }
    // base case
    // the compiler doesn't seem to get that doing rem == 0 would be
    // exhaustive here, as ints can only be 0, above 0, or below 0...
    // but i'm like 99% certain this base case will ONLY happen
    // when we want it to, even if it feels bad
    res, _ -> #(zero_ticks, res)
  }
}

fn rotate_with_ticks(a: UnsignedInt, b: Int) -> #(Int, Int) {
  rotate_helper(a, #(0, b))
}

// we can parse the input string into a list of standard ints
pub fn parse(input: String) -> List(Int) {
  string.split(input, on: "\n")
  |> list.map(with: fn(x) {
    case x {
      "L" <> number -> {
        int.parse(number)
        |> result.unwrap(0)
        |> int.negate()
      }
      "R" <> number -> {
        int.parse(number)
        |> result.unwrap(0)
      }
      _ -> 0
    }
  })
  |> list.filter(keeping: fn(x) { x != 0 })
}

pub fn pt_1(input: List(Int)) -> Int {
  echo input
  list.fold(
    over: input,
    from: #(0, UnsignedInt(n: 50, max: 99)),
    with: fn(cur, x) {
      // echo "current dial pos: " <> int.to_string(pair.second(cur).n)
      let #(wraps, res) = rotate(pair.second(cur), x, False)
      // echo "wraps: " <> int.to_string(wraps)
      // echo "res: " <> int.to_string(res)
      // echo "cur: " <> int.to_string(pair.second(cur).n)
      case res {
        0 -> #(pair.first(cur) + 1, UnsignedInt(0, pair.second(cur).max))
        x -> #(pair.first(cur), UnsignedInt(x, pair.second(cur).max))
      }
    },
  )
  |> pair.first()
}

pub fn pt_2(input: List(Int)) -> Int {
  list.fold(
    over: input,
    from: #(0, UnsignedInt(n: 50, max: 99)),
    with: fn(cur, x) {
      let #(wraps, res) = rotate(pair.second(cur), x, True)
      // echo "current dial pos: " <> int.to_string(pair.second(cur).n)
      // echo "wraps: " <> int.to_string(wraps)
      // echo "res: " <> int.to_string(res)
      // #(pair.first(cur) + wraps, UnsignedInt(res, pair.second(cur).max))
      case res {
        0 -> #(pair.first(cur) + wraps, UnsignedInt(0, pair.second(cur).max))
        x -> #(pair.first(cur) + wraps, UnsignedInt(x, pair.second(cur).max))
      }
    },
  )
  |> pair.first()
}

fn unsigned_add(a: UnsignedInt, b: Int) -> #(Int, Int) {
  // it takes the maximum of the uint plus 1 steps to wrap
  // so if we do an integer division b // uint.max + 1, that gets the wraps
  // thus we just need to add the modulo of uint.max + 1 and the additor
  let full_wrap = a.max + 1
  let uncapped_result = a.n + b
  let wraps = uncapped_result / full_wrap
  let remainder = uncapped_result % full_wrap
  // echo "unsigned add"
  // echo "b: " <> int.to_string(b)
  // echo "uncapped_result: " <> int.to_string(uncapped_result)
  // echo "wraps: " <> int.to_string(wraps)
  // echo "remainder: " <> int.to_string(remainder)

  // case all_wraps {
  //   True -> {
  //     case uncapped_result {
  //       r if r > a.max -> #(wraps + 1, remainder)
  //       n -> #(wraps, n)
  //     }
  //   }
  //   False -> {
  let res = case uncapped_result {
    r if r > a.max -> #(0, remainder)
    n -> #(0, n)
  }
  case pair.second(res) {
    100 -> {
      echo b
      echo res
    }
    _ -> res
  }
}

fn unsigned_add_all_wraps(a: UnsignedInt, b: Int) -> #(Int, Int) {
  // it takes the maximum of the uint plus 1 steps to wrap
  // so if we do an integer division b // uint.max + 1, that gets the wraps
  // thus we just need to add the modulo of uint.max + 1 and the additor
  let full_wrap = a.max + 1
  let uncapped_result = a.n + b
  let wraps = uncapped_result / full_wrap
  let remainder = uncapped_result % full_wrap
  // echo "unsigned add"
  // echo "b: " <> int.to_string(b)
  // echo "uncapped_result: " <> int.to_string(uncapped_result)
  // echo "wraps: " <> int.to_string(wraps)
  // echo "remainder: " <> int.to_string(remainder)

  let res = case wraps, uncapped_result {
    0, r if r > a.max -> #(1, remainder)
    wraps, r if r > a.max -> #(wraps, remainder)
    wraps, n -> #(wraps, n)
  }

  case pair.second(res) {
    100 -> {
      echo b
      echo res
    }
    _ -> res
  }
}

fn unsigned_subtract(a: UnsignedInt, b: Int) -> #(Int, Int) {
  let full_wrap = a.max + 1
  let uncapped_result = a.n - b
  // let wraps = int.absolute_value(uncapped_result / full_wrap)
  let remainder = int.absolute_value(uncapped_result % full_wrap)
  let res = case uncapped_result {
    r if r < 0 -> {
      #(1, a.max + 1 - remainder)
    }
    r if r == 100 -> #(1, 0)
    r -> #(0, r)
  }
  case pair.second(res) {
    100 -> {
      echo b
      echo res
    }
    _ -> res
  }
}

fn unsigned_subtract_all_wraps(a: UnsignedInt, b: Int) -> #(Int, Int) {
  let full_wrap = a.max + 1
  let uncapped_result = a.n - b
  let wraps = int.absolute_value(uncapped_result / full_wrap)
  let remainder = int.absolute_value(uncapped_result % full_wrap)
  // echo "unsigned sub"
  // echo "wraps: " <> int.to_string(wraps)
  // echo "remainder: " <> int.to_string(remainder)

  let res = case wraps, uncapped_result {
    0, r if r < 0 -> {
      #(1, a.max + 1 - remainder)
    }
    wraps, r if r < 0 -> {
      #(wraps + 1, a.max + 1 - remainder)
    }
    wraps, r if r == 100 -> #(wraps + 1, 0)
    wraps, r -> #(wraps, r)
  }
  case pair.second(res) {
    100 -> {
      echo b
      echo res
    }
    _ -> res
  }
}

fn rotate(a: UnsignedInt, b: Int, all_wraps: Bool) -> #(Int, Int) {
  case all_wraps {
    True -> {
      case b {
        b if b < 0 -> unsigned_subtract_all_wraps(a, int.absolute_value(b))
        b if b > 0 -> unsigned_add_all_wraps(a, b)
        _ -> #(0, a.n)
      }
    }
    False -> {
      case b {
        b if b < 0 -> unsigned_subtract(a, int.absolute_value(b))
        b if b > 0 -> unsigned_add(a, b)
        _ -> #(0, a.n)
      }
    }
  }
}
