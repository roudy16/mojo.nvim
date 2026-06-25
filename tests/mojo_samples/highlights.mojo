# Test file for mojo.nvim highlights.scm updates
# grammar: tree-sitter-mojo PR #10

# --- 0. Basic literals ---

var yes = True                           # (true) @constant.builtin
var no = False                           # (false) @constant.builtin
var nothing = None                       # (none) @constant.builtin

# --- 1. Function effects (raises_clause removed, now keyword tokens) ---

def func_no_return() raises:               # "raises" should be @keyword
    pass

def func_typed_raises() raises Error:      # "raises" @keyword, Error @type
    pass

def func_effects() raises capturing:       # "raises" + "capturing" both @keyword
    pass

def func_thin() thin:                      # "thin" @keyword
    pass

# --- 2. New keywords ---

@parameter
def test_abi() abi("C"):                   # "abi" @keyword
    pass

@value
struct MyStruct(Sized, Comparable):
    pass

type MyAlias = Int                        # "type" @keyword
var my_var: Int = 42                       # "var" @keyword

# --- 3. Argument conventions (@keyword.modifier) ---

def read_param(inout buf: Tensor, borrowed other: Tensor):
    pass

def multi_ref(ref[origin] self: Tensor):
    pass

# --- 4. MLIR interop ---

fn mlir_example():
    var t = __mlir_type.index              # "index" in mlir_type @type
    var attr = __mlir_type.`!co.routine`

# --- 5. Punctuation brackets ---

var lst = [1, 2, (3 + 4)]                 # ()[]{} should be @punctuation.bracket

# --- 6. Builtins (updated list) ---

var length = len(items)                    # "len" @function.builtin
var result = unroll(my_array)              # "unroll" @function.builtin

# --- 7. Constants with leading underscore ---

var __VERSION__: String = "1.0"            # @constant (leading underscore)
var MAX_SIZE: Int = 1024                      # @constant

# --- 8. Docstring ---

fn documented():
    """This is a docstring"""             # @string.doc
    pass

# --- 9. Intersection & callable types ---

type MyBound = Copyable & RegisterPassable          # "&" @operator
type CallableType = def(Int) -> Int                 # callable type literal

# --- 10. comptime control flow ---

comptime if MOJO_VERSION >= 24:          # "comptime" @keyword
    print("new features")

comptime for x in range(5):             # "comptime" @keyword
    pass

# --- 11. Transfer expression ---

def transfer_example() raises:
    return result^                       # postfix ^ operator
    pass

# --- 12. Extension definition ---

__extension List:
    pass

# --- 13. Typed self ---

struct Buffer:
    fn __setitem__(self: Buffer[Self.dtype], idx: Int):
        pass

# Standalone self usage
fn use_self():
    self.method()                        # "self" @variable.builtin

# --- 14. Struct literals ---

var point = {x = 10, y = 20}            # struct literal

# --- 15. Comptime alias with parameters ---

comptime Ptr[mut: Bool] = IntPointer     # "comptime" @keyword
