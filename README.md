# lua

Embed Lua in Carp. Provides two modules: `Lua` for direct access to the Lua C
API, and `Luax` for a safer, higher-level interface built on top of it.

## Installation

```clojure
(load "https://github.com/carpentry-org/lua@0.4.0")

; tell Carp where your Lua headers live
(Lua.setup "lua")

; if your library is named differently (e.g. lua5.4):
(Lua.setup "lua" "lua5.4")
```

## Usage

All interaction happens inside a `Lua.with-lua-do` block, which creates a Lua
state and closes it when the block exits:

```clojure
(defn main []
  (Lua.with-lua-do
    (Lua.libs lua)

    ; define and call a Lua function
    (ignore (Lua.fun lua add [x y] "return x + y"))
    (let [result (Luax.call-fn lua add Lua.get-int
                   (Lua.push-int 3)
                   (Lua.push-int 4))]
      (match result
        (Result.Success v) (IO.println &(fmt "3 + 4 = %d" v))
        (Result.Error e) (IO.errorln &e)))))
```

The `Lua` module wraps the Lua C API directly: stack operations
(`push-int`, `push-double`, `push-bool`, `push-string`, `get-int`, etc.),
globals (`get-global`, `set-global`), tables (`create-table`, `set-field`,
`get-field`, `next`), code execution (`do-string`, `do-file`, `call`), and
type checking (`type-of`, `TYPE_NIL`, `TYPE_NUMBER`, etc.). It also provides a
few conveniences: `Lua.fun` for defining Lua functions inline, `Lua.val` for
evaluating Lua expressions into globals, and `Lua.eval-file` for loading Lua
files with error handling.

A Lua number is a C double, so `push-double` and `get-double` (and the matching
`Luax.set-double-global`, `Luax.get-double-field`, …) carry Lua floats at full
precision. The `float` versions still work — a float widens into a double
exactly — but `get-float` narrows on the way back, so reading through it drops
everything past single precision. Lua integers are a separate 64-bit subtype;
`get-double` converts them to doubles, so integers above 2^53 come back rounded.

The `Luax` module provides safe wrappers that return `Maybe` and `Result`
types instead of requiring manual type checks:

```clojure
; safe global access — returns Maybe
(Luax.set-int-global lua "score" 100)
(match (Luax.get-int-global lua "score")
  (Maybe.Just n) (IO.println &(fmt "score: %d" n))
  (Maybe.Nothing) (IO.errorln "not found"))

; build tables from Carp
(Luax.make-table lua player
  (name (Lua.push-carp-str "Ada"))
  (hp (Lua.push-int 100))
  (x (Lua.push-double 3.5))
  (y (Lua.push-double 7.0)))

; read table fields — returns Maybe, keeps the stack clean
(Lua.get-global lua (cstr "player"))
(match (Luax.get-string-field lua -1 "name")
  (Maybe.Just name) (IO.println &(fmt "name: %s" &name))
  (Maybe.Nothing) (IO.errorln "missing"))
(Lua.pop lua 1)

; execute Lua code with error handling
(match (Luax.do-in lua "x = 1 + nil")
  (Result.Success _) ()
  (Result.Error e) (IO.println &(fmt "caught: %s" &e)))
```

Full API documentation lives [here](https://veitheller.de/lua).

More examples are in the [`examples`](./examples) directory.

<hr/>

Have fun!
