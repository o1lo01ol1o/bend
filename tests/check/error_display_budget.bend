# error display budget: the expected side normalizes to a full binary
# tree of 2^20 nodes, past the display's normalization budget, so it
# prints unnormalized (d20) instead of spending minutes and gigabytes
# building the normal form before the error appears.
import Base

type T is Data:
  Leaf{}
  Node{l: T, r: T}

law d0:
  T

def d0():
  Leaf{}

law d1:
  T

def d1():
  Node{d0(), d0()}

law d2:
  T

def d2():
  Node{d1(), d1()}

law d3:
  T

def d3():
  Node{d2(), d2()}

law d4:
  T

def d4():
  Node{d3(), d3()}

law d5:
  T

def d5():
  Node{d4(), d4()}

law d6:
  T

def d6():
  Node{d5(), d5()}

law d7:
  T

def d7():
  Node{d6(), d6()}

law d8:
  T

def d8():
  Node{d7(), d7()}

law d9:
  T

def d9():
  Node{d8(), d8()}

law d10:
  T

def d10():
  Node{d9(), d9()}

law d11:
  T

def d11():
  Node{d10(), d10()}

law d12:
  T

def d12():
  Node{d11(), d11()}

law d13:
  T

def d13():
  Node{d12(), d12()}

law d14:
  T

def d14():
  Node{d13(), d13()}

law d15:
  T

def d15():
  Node{d14(), d14()}

law d16:
  T

def d16():
  Node{d15(), d15()}

law d17:
  T

def d17():
  Node{d16(), d16()}

law d18:
  T

def d18():
  Node{d17(), d17()}

law d19:
  T

def d19():
  Node{d18(), d18()}

law d20:
  T

def d20():
  Node{d19(), d19()}

law main:
  {d20() == Leaf{} : T}

def main():
  {==}

#|SOME PROOFS FAIL
#|Error:
#|- expected : d20
#|- observed : Leaf{}
#|Location: main
#|140 | def main():
#|141>|   {==}
#|    |   ^^^^
#|142 | 
#|Note: the left side of the equality is the expected, the right side is the observed.
#|exit 1
