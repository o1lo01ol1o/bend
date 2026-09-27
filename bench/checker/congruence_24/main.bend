# Transparent type-tree conversion: identical spines need no unfolding.
import Base

def T1(-A: Type) -> Type:
  A & A

def T2(-A: Type) -> Type:
  T1(A) & T1(A)

def T3(-A: Type) -> Type:
  T2(A) & T2(A)

def T4(-A: Type) -> Type:
  T3(A) & T3(A)

def T5(-A: Type) -> Type:
  T4(A) & T4(A)

def T6(-A: Type) -> Type:
  T5(A) & T5(A)

def T7(-A: Type) -> Type:
  T6(A) & T6(A)

def T8(-A: Type) -> Type:
  T7(A) & T7(A)

def T9(-A: Type) -> Type:
  T8(A) & T8(A)

def T10(-A: Type) -> Type:
  T9(A) & T9(A)

def T11(-A: Type) -> Type:
  T10(A) & T10(A)

def T12(-A: Type) -> Type:
  T11(A) & T11(A)

def T13(-A: Type) -> Type:
  T12(A) & T12(A)

def T14(-A: Type) -> Type:
  T13(A) & T13(A)

def T15(-A: Type) -> Type:
  T14(A) & T14(A)

def T16(-A: Type) -> Type:
  T15(A) & T15(A)

def T17(-A: Type) -> Type:
  T16(A) & T16(A)

def T18(-A: Type) -> Type:
  T17(A) & T17(A)

def T19(-A: Type) -> Type:
  T18(A) & T18(A)

def T20(-A: Type) -> Type:
  T19(A) & T19(A)

def T21(-A: Type) -> Type:
  T20(A) & T20(A)

def T22(-A: Type) -> Type:
  T21(A) & T21(A)

def T23(-A: Type) -> Type:
  T22(A) & T22(A)

def T24(-A: Type) -> Type:
  T23(A) & T23(A)

def hold(-A: Type, v: T24(A)) -> T24(A):
  v

def main() -> Nat:
  0n
