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
    x -> UnsignedInt(a.n - 1, a.max)
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
  list.fold(
    over: input,
    from: #(0, UnsignedInt(n: 50, max: 99)),
    with: fn(acc, x) {
      // we can just ignore the incidental zero ticks
      let #(_, res) = rotate_with_ticks(pair.second(acc), x)
      case res {
        0 -> #(pair.first(acc) + 1, UnsignedInt(0, pair.second(acc).max))
        x -> #(pair.first(acc), UnsignedInt(x, pair.second(acc).max))
      }
    },
  )
  |> pair.first()
}

pub fn pt_2(input: List(Int)) -> Int {
  list.fold(
    over: input,
    from: #(0, UnsignedInt(n: 50, max: 99)),
    with: fn(acc, x) {
      let #(zero_ticks, res) = rotate_with_ticks(pair.second(acc), x)
      #(zero_ticks + pair.first(acc), UnsignedInt(res, pair.second(acc).max))
    },
  )
  |> pair.first()
}

// here be dragons
//
// my original approach was to just do direct integer maths
// and handle overflows
// and i know this can work, i want to make this approach work eventually
// but for now. just tick it lol who cares about function calls
fn unsigned_add_helper(a: UnsignedInt, b: Int) -> Int {
  case b {
    n if n == 0 -> a.n
    n if n < 0 -> unsigned_add_helper(backward_tick(a), n + 1)
    n if n > 0 -> unsigned_add_helper(forward_tick(a), n - 1)
    _ -> panic
  }
}

fn overflow_add(a: UnsignedInt, b: Int) {
  case a.n - b {
    x if x > a.max -> {
      // echo "we have overflow"
      x - a.max - 1
    }
    underflow if underflow < 0 -> {
      // echo "we have underflow"
      a.max + 1 + underflow
    }
    x -> {
      x
    }
  }
}

fn unsigned_add(a: UnsignedInt, b: Int) -> Int {
  // it takes the maximum of the uint plus 1 steps to wrap
  // so if we do an integer division b // uint.max + 1, that gets the wraps
  // thus we just need to add the modulo of uint.max + 1 and the additor
  let full_wrap = a.max + 1
  let _wraps = full_wrap / b
  let remainder = full_wrap % b

  overflow_add(a, remainder)
}

fn overflow_subtract(a: UnsignedInt, b: Int) {
  echo "a: " <> int.to_string(a.n)
  echo "b: " <> int.to_string(b)
  echo "we should have " <> int.to_string(a.n - b)
  case a.n + b {
    x if x > a.max -> {
      echo "we have overflow"
      echo x - a.max - 1
    }
    underflow if underflow < 0 -> {
      echo "we have underflow"
      echo a.max + 1 + underflow
    }
    x -> {
      echo x
    }
  }
}

fn unsigned_subtract(a: UnsignedInt, b: Int) -> Int {
  // it takes the maximum of the uint plus 1 steps to wrap
  // so if we do an integer division b // uint.max + 1, that gets the wraps
  // thus we just need to add the modulo of uint.max + 1 and the additor
  let full_wrap = a.max + 1
  let wraps = full_wrap / b
  let remainder = full_wrap % b
  echo "full_wrap: " <> int.to_string(full_wrap)
  echo "wraps: " <> int.to_string(wraps)
  echo "remainder: " <> int.to_string(remainder)

  overflow_subtract(a, remainder)
}

// i wanna figure this out without the insane recursion
// but that's a later task lol
fn rotate(a: UnsignedInt, b: Int) -> Int {
  echo "b: " <> int.to_string(b)
  case b {
    b if b < 0 -> unsigned_subtract(a, b)
    b if b > 0 -> unsigned_add(a, b)
    _ -> 0
  }
}
