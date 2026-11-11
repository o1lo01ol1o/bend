# The errors reported are the first failing file's: both of the imported
# Lib's, and none of this file's, which is never checked.
import Base
import ./multi_error/Lib.bend as Lib

def entry_bad(n: Nat) -> Nat:
  "entry"

def main() -> Nat:
  0n

#|SOME PROOFS FAIL
#|Error:
#|- expected : Nat
#|- observed : String
#|Context:
#|- n : Nat
#|Location: lib_bad
#|3 | def lib_bad(n: Nat) -> Nat:
#|4>|   "lib"
#|  |   ^^^^^
#|5 |
#|
#|Error:
#|- expected : Nat
#|- observed : U32
#|Context:
#|- n : Nat
#|Location: lib_bad2
#|6 | def lib_bad2(n: Nat) -> Nat:
#|7>|   7
#|  |   ^
#|8 |
#|
#|Found 2 errors.
#|exit 1
