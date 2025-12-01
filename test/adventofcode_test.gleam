import aoc_2025/day_1
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn day1_test_input() -> String {
  "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
"
}

pub fn day1_parse_test() {
  assert [-68, -30, 48, -5, 60, -55, -1, -99, 14, -82]
    == day_1.parse(day1_test_input())
}

pub fn day1_pt_1_test() {
  assert 3 == day_1.pt_1(day_1.parse(day1_test_input()))
}

pub fn day1_pt_2_test() {
  assert 6 == day_1.pt_2(day_1.parse(day1_test_input()))
}
