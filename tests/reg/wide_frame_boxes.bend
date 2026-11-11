# regression witness: two 130-field rows live across a call. The
# continuation after depth's call held both unpacked, 260 words past 247,
# and the C lane refused it ("an arity over 247"). A frame that wide now
# boxes its multi-word values, as fun_of boxes a wide call's arguments.
import Base

type Row is Data:
  MkRow{f0: U32, f1: U32, f2: U32, f3: U32, f4: U32, f5: U32, f6: U32, f7: U32, f8: U32, f9: U32, f10: U32, f11: U32, f12: U32, f13: U32, f14: U32, f15: U32, f16: U32, f17: U32, f18: U32, f19: U32, f20: U32, f21: U32, f22: U32, f23: U32, f24: U32, f25: U32, f26: U32, f27: U32, f28: U32, f29: U32, f30: U32, f31: U32, f32: U32, f33: U32, f34: U32, f35: U32, f36: U32, f37: U32, f38: U32, f39: U32, f40: U32, f41: U32, f42: U32, f43: U32, f44: U32, f45: U32, f46: U32, f47: U32, f48: U32, f49: U32, f50: U32, f51: U32, f52: U32, f53: U32, f54: U32, f55: U32, f56: U32, f57: U32, f58: U32, f59: U32, f60: U32, f61: U32, f62: U32, f63: U32, f64: U32, f65: U32, f66: U32, f67: U32, f68: U32, f69: U32, f70: U32, f71: U32, f72: U32, f73: U32, f74: U32, f75: U32, f76: U32, f77: U32, f78: U32, f79: U32, f80: U32, f81: U32, f82: U32, f83: U32, f84: U32, f85: U32, f86: U32, f87: U32, f88: U32, f89: U32, f90: U32, f91: U32, f92: U32, f93: U32, f94: U32, f95: U32, f96: U32, f97: U32, f98: U32, f99: U32, f100: U32, f101: U32, f102: U32, f103: U32, f104: U32, f105: U32, f106: U32, f107: U32, f108: U32, f109: U32, f110: U32, f111: U32, f112: U32, f113: U32, f114: U32, f115: U32, f116: U32, f117: U32, f118: U32, f119: U32, f120: U32, f121: U32, f122: U32, f123: U32, f124: U32, f125: U32, f126: U32, f127: U32, f128: U32, f129: U32}

def row(+n: U32) -> Row:
  MkRow{U32.add(n, 0), U32.add(n, 1), U32.add(n, 2), U32.add(n, 3), U32.add(n, 4), U32.add(n, 5), U32.add(n, 6), U32.add(n, 7), U32.add(n, 8), U32.add(n, 9), U32.add(n, 10), U32.add(n, 11), U32.add(n, 12), U32.add(n, 13), U32.add(n, 14), U32.add(n, 15), U32.add(n, 16), U32.add(n, 17), U32.add(n, 18), U32.add(n, 19), U32.add(n, 20), U32.add(n, 21), U32.add(n, 22), U32.add(n, 23), U32.add(n, 24), U32.add(n, 25), U32.add(n, 26), U32.add(n, 27), U32.add(n, 28), U32.add(n, 29), U32.add(n, 30), U32.add(n, 31), U32.add(n, 32), U32.add(n, 33), U32.add(n, 34), U32.add(n, 35), U32.add(n, 36), U32.add(n, 37), U32.add(n, 38), U32.add(n, 39), U32.add(n, 40), U32.add(n, 41), U32.add(n, 42), U32.add(n, 43), U32.add(n, 44), U32.add(n, 45), U32.add(n, 46), U32.add(n, 47), U32.add(n, 48), U32.add(n, 49), U32.add(n, 50), U32.add(n, 51), U32.add(n, 52), U32.add(n, 53), U32.add(n, 54), U32.add(n, 55), U32.add(n, 56), U32.add(n, 57), U32.add(n, 58), U32.add(n, 59), U32.add(n, 60), U32.add(n, 61), U32.add(n, 62), U32.add(n, 63), U32.add(n, 64), U32.add(n, 65), U32.add(n, 66), U32.add(n, 67), U32.add(n, 68), U32.add(n, 69), U32.add(n, 70), U32.add(n, 71), U32.add(n, 72), U32.add(n, 73), U32.add(n, 74), U32.add(n, 75), U32.add(n, 76), U32.add(n, 77), U32.add(n, 78), U32.add(n, 79), U32.add(n, 80), U32.add(n, 81), U32.add(n, 82), U32.add(n, 83), U32.add(n, 84), U32.add(n, 85), U32.add(n, 86), U32.add(n, 87), U32.add(n, 88), U32.add(n, 89), U32.add(n, 90), U32.add(n, 91), U32.add(n, 92), U32.add(n, 93), U32.add(n, 94), U32.add(n, 95), U32.add(n, 96), U32.add(n, 97), U32.add(n, 98), U32.add(n, 99), U32.add(n, 100), U32.add(n, 101), U32.add(n, 102), U32.add(n, 103), U32.add(n, 104), U32.add(n, 105), U32.add(n, 106), U32.add(n, 107), U32.add(n, 108), U32.add(n, 109), U32.add(n, 110), U32.add(n, 111), U32.add(n, 112), U32.add(n, 113), U32.add(n, 114), U32.add(n, 115), U32.add(n, 116), U32.add(n, 117), U32.add(n, 118), U32.add(n, 119), U32.add(n, 120), U32.add(n, 121), U32.add(n, 122), U32.add(n, 123), U32.add(n, 124), U32.add(n, 125), U32.add(n, 126), U32.add(n, 127), U32.add(n, 128), U32.add(n, 129)}

def ends(r: Row) -> U32:
  match r:
    case MkRow{first, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, last}:
      U32.add(first, last)

def depth(n: Nat) -> U32:
  match n:
    case 0n: 0
    case 1n+p: U32.add(depth(p), 1)

def main() -> U32:
  a = row(1000)
  b = row(2000)
  d = depth(1000n)
  U32.add(d, U32.add(ends(a), ends(b)))

#|7258
