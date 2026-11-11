# A failed template turns opaque; its caller is skipped, and an
# independent def after it is still checked.
import Base

def pad(~k: Nat, n: Nat) -> Nat:
  "pad"

def caller(n: Nat) -> Nat:
  pad(3n, n)

def other(n: Nat) -> U32:
  n

def main() -> Nat:
  0n

#|SOME PROOFS FAIL
#|Error:
#|- expected : Nat
#|- observed : String
#|Context:
#|- n : Nat
#|Location: pad
#|5 | def pad(~k: Nat, n: Nat) -> Nat:
#|6>|   "pad"
#|  |   ^^^^^
#|7 |
#|
#|Error:
#|- expected : U32
#|- observed : Nat
#|Context:
#|- n : Nat
#|Location: other
#|11 | def other(n: Nat) -> U32:
#|12>|   n
#|   |   ^
#|13 |
#|
#|Found 2 errors. 1 def that names a failed def was not checked.
#|exit 1
