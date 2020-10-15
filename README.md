# lua

is a simple way to embed Lua in Carp that is currently WIP.

## Usage

```clojure
(load "https://github.com/carpentry-org/lua@master")

; this depends on where your Lua headers are;
; mine are in /usr/local/include, in the subdirectory
; lua, so we need to tell Carp about that directory
(Lua.setup "lua")

; will return a string representation of the value
(Lua.evaluate "1 + 1") ; => "2"
```

<hr/>

Have fun!
