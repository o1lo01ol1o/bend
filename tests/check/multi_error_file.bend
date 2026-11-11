# Past a failed def the checker goes on to the end of its file: bad2 is
# reported too; uses_bad1 names a failed def, so it is not checked (it
# would only repeat bad1's error), and the count says so.
import Base

def ok(n: Nat) -> Nat:
  n

def bad1(n: Nat) -> Nat:
  "one"

def uses_bad1(n: Nat) -> Nat:
  bad1(n)

def fine(n: Nat) -> Nat:
  ok(n)

def bad2(n: Nat) -> U32:
  n

def main() -> Nat:
  fine(1n)

#|SOME PROOFS FAIL
#|Error:
#|- expected : Nat
#|- observed : String
#|Context:
#|- n : Nat
#|Location: bad1
#| 9 | def bad1(n: Nat) -> Nat:
#|10>|   "one"
#|   |   ^^^^^
#|11 |
#|
#|Error:
#|- expected : U32
#|- observed : Nat
#|Context:
#|- n : Nat
#|Location: bad2
#|18 | def bad2(n: Nat) -> U32:
#|19>|   n
#|   |   ^
#|20 |
#|
#|Found 2 errors. 1 def that names a failed def was not checked.
#|exit 1
