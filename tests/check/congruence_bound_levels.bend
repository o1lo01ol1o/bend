# Alpha-congruence must distinguish binder levels, not just binder names.
import Base

law bad:
  {(x => y => x) == (x => y => y) : Nat -> Nat -> Nat}

def bad(): {==}
# The inner variable is not the outer one.

#|Error:
#|- expected : x => y => x
#|- observed : x => y => y
#|Location: bad
#|6 |
#|7>| def bad(): {==}
#|8 | # The inner variable is not the outer one.
#|exit 1
