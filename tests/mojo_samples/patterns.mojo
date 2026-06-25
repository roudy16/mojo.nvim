# Patterns — match/case, destructuring, splats

# Simple match
match value:
    case 0:
        print("zero")
    case 1:
        print("one")
    case _:
        print("other")

# Match with guards
match x:
    case n if n > 0:
        print("positive")
    case n if n < 0:
        print("negative")

# Tuple/list patterns
match pair:
    case (0, 0):
        print("origin")
    case (x, 0):
        print("on x-axis")
    case (0, y):
        print("on y-axis")
    case (x, y):
        print(f"({x}, {y})")

match items:
    case [first, *rest]:
        print(first)

# Dict/struct patterns
match obj:
    case {"key": value}:
        print(value)

# Class patterns
match shape:
    case Circle(radius=r):
        print(f"circle r={r}")
    case Rect(width=w, height=h):
        print(f"rect {w}x{h}")

# Or patterns (multiple alternatives)
match status:
    case 200 | 201 | 204:
        print("ok")

# Splat patterns
var first, *middle, last = items
var (a, b) = pair

# Named expression (walrus) in patterns
match result:
    case (x, y) if (s := x + y) > 0:
        print(s)

# As patterns
match val:
    case int() as n:
        print(n)

# Keyword patterns
match ctx:
    case {"name": n, "version": v}:
        print(f"{n} v{v}")
