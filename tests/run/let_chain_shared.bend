# a type built from a chain of 24 lets, T_i = T_{i-1} & T_{i-1}, under a
# live value of type Maybe<T_24>: each let's value is one object behind
# both uses of its variable, so its unshared tree has 2^24 leaves. The C
# lane keyed every type it met by the text of that tree (ty_key, through
# facts_hot and lay_of), so building this took 2.4 s at 18 lets and over
# 150 s at 24; keyed by term_id, a shared value is keyed once.
import Base

def pick(-T: Type, m: Maybe<&1, T>) -> U32:
  match m:
    case None{}:
      7
    case Some{v}:
      1

def main() -> U32:
  T0 = U32
  T1 = T0 & T0
  T2 = T1 & T1
  T3 = T2 & T2
  T4 = T3 & T3
  T5 = T4 & T4
  T6 = T5 & T5
  T7 = T6 & T6
  T8 = T7 & T7
  T9 = T8 & T8
  T10 = T9 & T9
  T11 = T10 & T10
  T12 = T11 & T11
  T13 = T12 & T12
  T14 = T13 & T13
  T15 = T14 & T14
  T16 = T15 & T15
  T17 = T16 & T16
  T18 = T17 & T17
  T19 = T18 & T18
  T20 = T19 & T19
  T21 = T20 & T20
  T22 = T21 & T21
  T23 = T22 & T22
  T24 = T23 & T23
  m : Maybe<&1, T24> = None{}
  pick(T24, m)

#|7
