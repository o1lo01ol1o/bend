# Sharing cells all use negative indices. Distinct values in them must not
# become equal merely because their storage cells have the same index.
import Base

def id_nat(x: Nat) -> Nat:
  x

def bad(+x: Nat, +y: Nat) -> {id_nat(x) == id_nat(y) : Nat}:
  {==}
# Distinct variables are not definitionally equal.

#|SOME PROOFS FAIL
#|Error:
#|- expected : x
#|- observed : y
#|Context:
#|- x : Nat
#|- y : Nat
#|Location: bad
#| 8 | def bad(+x: Nat, +y: Nat) -> {id_nat(x) == id_nat(y) : Nat}:
#| 9>|   {==}
#|   |   ^^^^
#|10 | # Distinct variables are not definitionally equal.
#|Note: the left side of the equality is the expected, the right side is the observed.
#|exit 1
