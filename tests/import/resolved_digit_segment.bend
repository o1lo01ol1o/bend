# the path an import is written as is a path of plain names, but the path
# it resolves to may hold a segment that starts with a digit: a link into
# /nix/store/<hash>-source reaches a hash that often does, and the module
# was refused ("resolves to ...") whenever the hash happened to. Here
# resolved-digit/linked is a link to resolved-digit/7store.
import Base
import ./resolved-digit/linked/Lib.bend as L

def main() -> U32:
  L.seven()

#|7
