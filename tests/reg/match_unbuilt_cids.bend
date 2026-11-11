# regression witness: a match on a datatype the program never builds.
# The C header declared CID_ macros only for datatypes something builds
# (FL.srcs), and still's type D(s) names TwoD through a family, so its Two
# arm compared CID_Even and CID_Swapped, undeclared, and the C did not
# compile. A match now registers its datatype as a build does.
import Base

type Shape is Data:
  One{}
  Two{}

type OneD is Data:
  Kept{}
  Moved{by: U32}

type TwoD is Data:
  Even{}
  Swapped{}

def D(s: Shape) -> Data:
  match s:
    case One{}: OneD
    case Two{}: TwoD

def still(s: Shape, d: D(s)) -> U32:
  match s d:
    case One{} Kept{}: 1
    case One{} Moved{by}: by
    case Two{} Even{}: 2
    case Two{} Swapped{}: 3

def sum(n: Nat, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: sum(p, still(One{}, Moved{U32.mul(acc, 2)}))

def main() -> U32:
  sum(10n, 1)

#|1024
