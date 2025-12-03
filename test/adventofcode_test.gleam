import aoc_2025/day_1
import aoc_2025/day_2
import aoc_2025/day_3
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

fn day2_test_data() {
  "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
}

pub fn day2_parse_test() {
  assert Ok([
      #(11, 22),
      #(95, 115),
      #(998, 1012),
      #(1_188_511_880, 1_188_511_890),
      #(222_220, 222_224),
      #(1_698_522, 1_698_528),
      #(446_443, 446_449),
      #(38_593_856, 38_593_862),
      #(565_653, 565_659),
      #(824_824_821, 824_824_827),
      #(2_121_212_118, 2_121_212_124),
    ])
    == day_2.parse(day2_test_data())
}

pub fn day2_invalid_ids_pair_test() {
  assert [11, 22] == day_2.invalid_ids(#(11, 22), day_2.is_invalid_pair)
  assert [99] == day_2.invalid_ids(#(95, 115), day_2.is_invalid_pair)
  assert [1010] == day_2.invalid_ids(#(998, 1012), day_2.is_invalid_pair)
  assert [1_188_511_885]
    == day_2.invalid_ids(#(1_188_511_880, 1_188_511_890), day_2.is_invalid_pair)
  assert [222_222]
    == day_2.invalid_ids(#(222_220, 222_224), day_2.is_invalid_pair)
  assert [] == day_2.invalid_ids(#(1_698_522, 1_698_528), day_2.is_invalid_pair)
  assert [446_446]
    == day_2.invalid_ids(#(446_443, 446_449), day_2.is_invalid_pair)
  assert [38_593_859]
    == day_2.invalid_ids(#(38_593_856, 38_593_862), day_2.is_invalid_pair)
  assert [] == day_2.invalid_ids(#(565_653, 565_659), day_2.is_invalid_pair)
  assert []
    == day_2.invalid_ids(#(824_824_821, 824_824_827), day_2.is_invalid_pair)
  assert []
    == day_2.invalid_ids(#(2_121_212_118, 2_121_212_124), day_2.is_invalid_pair)
}

pub fn day2_pt_1_test() {
  let ranges = day_2.parse(day2_test_data())

  assert 1_227_775_554 == day_2.pt_1(ranges)
}

pub fn day2_invalid_ids_all_test() {
  assert [11, 22] == day_2.invalid_ids(#(11, 22), day_2.is_invalid_all)
  assert [99, 111] == day_2.invalid_ids(#(95, 115), day_2.is_invalid_all)
  assert [999, 1010] == day_2.invalid_ids(#(998, 1012), day_2.is_invalid_all)
  assert [1_188_511_885]
    == day_2.invalid_ids(#(1_188_511_880, 1_188_511_890), day_2.is_invalid_all)
  assert [222_222]
    == day_2.invalid_ids(#(222_220, 222_224), day_2.is_invalid_all)
  assert [] == day_2.invalid_ids(#(1_698_522, 1_698_528), day_2.is_invalid_all)
  assert [446_446]
    == day_2.invalid_ids(#(446_443, 446_449), day_2.is_invalid_all)
  assert [38_593_859]
    == day_2.invalid_ids(#(38_593_856, 38_593_862), day_2.is_invalid_all)
  assert [565_656]
    == day_2.invalid_ids(#(565_653, 565_659), day_2.is_invalid_all)
  assert [824_824_824]
    == day_2.invalid_ids(#(824_824_821, 824_824_827), day_2.is_invalid_all)
  assert [2_121_212_121]
    == day_2.invalid_ids(#(2_121_212_118, 2_121_212_124), day_2.is_invalid_all)
}

pub fn day2_pt_2_test() {
  let ranges = day_2.parse(day2_test_data())

  assert 4_174_379_265 == day_2.pt_2(ranges)
}

fn day3_single_bank_test() -> List(List(Int)) {
  day_3.parse("987654321111111")
}

fn day3_test_data() -> List(List(Int)) {
  day_3.parse(
    "987654321111111
811111111111119
234234234234278
818181911112111",
  )
}

fn day3_awkward_case() -> List(List(Int)) {
  day_3.parse("818181911112111")
}

fn day3_bank_2_test_data() -> List(List(Int)) {
  day_3.parse("811111111111119")
}

fn day3_bank_3_test_data() -> List(List(Int)) {
  day_3.parse("234234234234278")
}

pub fn day3_parse_test() {
  assert [[9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1]]
    == day3_single_bank_test()
}

pub fn day3_pt_1_test() {
  assert 98 == day_3.pt_1(day3_single_bank_test())

  assert 89 == day_3.pt_1(day3_bank_2_test_data())

  assert 78 == day_3.pt_1(day3_bank_3_test_data())

  assert 92 == day_3.pt_1(day3_awkward_case())

  assert 357 == day_3.pt_1(day3_test_data())
}
