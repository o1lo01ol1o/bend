# regression witness: a loop's U32 result in a slot another arm boxes.
# Num's n shares its slot with Label's String, so the slot is a box; the
# two copies of t kept the word as a term, emitting
# `(u32)_o_0[0] = term_keep(e, (u32)_o_0[0], 1)`, an lvalue cast the C
# compiler refuses. A raw u32 is a trivial term, so it is not kept.
import Base

type Tally is Data:
  Num{n: U32}
  Label{s: String}

def count(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: count(p, U32.add(acc, 3))

def weight(t: Tally) -> U32:
  match t:
    case Num{n}: n
    case Label{s}: 0

def both(a: Tally, b: Tally) -> List<Tally>:
  [a, b]

def total(xs: List<Tally>) -> U32:
  match xs:
    case []:
      0
    case h <> t:
      U32.add(weight(h), total(t))

def main() -> U32:
  +t = {Num{count(100000n, 0)} : Tally}
  total(both(t, t))

#|600000
