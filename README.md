# JuliaMacroCheatSheet
Macro CheatSheet


Note: Linenumbers are removed from the CheatSheet!
All test has included: `using Base.Meta: quot, QuoteNode`

Big mistakes: `$QuoteNode(…)` instead of `$(QuoteNode(…))` 


Case - Basic expressions:

```julia
x=:p   # Main.x
p=7   # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym)</code></td>
    <td><code>@sym</code></td>
    <td><code>eval(@sym)</code></td>
    <td><code>eval(eval(@sym))</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :x; end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(x); end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); QuoteNode(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quote; :x; end end</code></td>
    <td><code>quote
    :x
end</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
</table>

Case - Global space basic expressions:

```julia
x=:p   # Main.x
p=7   # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym)</code></td>
    <td><code>@sym</code></td>
    <td><code>eval(@sym)</code></td>
    <td><code>eval(eval(@sym))</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :($x); end</code></td>
    <td><code>:(Main.p)</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :($(esc(x))); end</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(x); end</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
</table>

Case - Medium expression:

```julia
ex=:ey  # Main.ex
x=:p    # Main.x
p=7     # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@fn x)</code></td>
    <td><code>@fn x</code></td>
    <td><code>eval(@fn x)</code></td>
    <td><code>eval(eval(@fn x))</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); ex; end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($ex); end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quote; $ex; end end</code></td>
    <td><code>quote
    Main.x
end</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($(esc(ex))); end</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quote; $(esc(ex)); end end</code></td>
    <td><code>quote
    x
end</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quot(ex); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); QuoteNode(ex); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :ex; end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>UndefVarError(:ez)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(ex); end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>UndefVarError(:ez)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($(:ex)); end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>UndefVarError(:ez)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(:ex); end</code></td>
    <td><code>:(:ex)</code></td>
    <td><code>:ex</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quot(:ex); end</code></td>
    <td><code>:(:ex)</code></td>
    <td><code>:ex</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); QuoteNode(:ex); end</code></td>
    <td><code>:(:ex)</code></td>
    <td><code>:ex</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quote; :ex; end end</code></td>
    <td><code>quote
    :ex
end</code></td>
    <td><code>:ex</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(string(ex)); end</code></td>
    <td><code>:(Main.string(Main.ex))</code></td>
    <td><code>"ey"</code></td>
    <td><code>"ey"</code></td>
    <td><code>"ey"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(string($ex)); end</code></td>
    <td><code>:(Main.string(Main.x))</code></td>
    <td><code>"p"</code></td>
    <td><code>"p"</code></td>
    <td><code>"p"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); string(ex); end</code></td>
    <td><code>"x"</code></td>
    <td><code>"x"</code></td>
    <td><code>"x"</code></td>
    <td><code>"x"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($(string(ex))); end</code></td>
    <td><code>"x"</code></td>
    <td><code>"x"</code></td>
    <td><code>"x"</code></td>
    <td><code>"x"</code></td>
  </tr>
</table>

Case - Basic:

```julia
ex=:ey   # Main.ex
x=:p     # Main.x
p=7      # Main.p
```
<table>
  <tr>
    <td>@fn x</td>
    <td><code>ex</code></td>
    <td><code>:ex</code></td>
    <td><code>string(ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:(ey)</code></td>
    <td><code>$(ex)</code></td>
    <td><code>$(esc(ex))</code></td>
    <td><code>$(string(ex))</code></td>
    <td><code>string($ex)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex)
 …
end</code></td>
    <td><code>:p</code></td>
    <td><code>:ey</code></td>
    <td><code>"x"</code></td>
    <td><code>:ez</code></td>
    <td><code>:ez</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex)
 quot(…)
end</code></td>
    <td><code>:x</code></td>
    <td><code>:ex</code></td>
    <td><code>"x"</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex)
 QuoteNode(…)
end</code></td>
    <td><code>:x</code></td>
    <td><code>:ex</code></td>
    <td><code>"x"</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex)
 :(…)
end</code></td>
    <td><code>:ey</code></td>
    <td><code>:ex</code></td>
    <td><code>"ey"</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>:p</code></td>
    <td><code>:p</code></td>
    <td><code>"x"</code></td>
    <td><code>"p"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex)
 quote
  …
 end
end</code></td>
    <td><code>:ey</code></td>
    <td><code>:ex</code></td>
    <td><code>"ey"</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>:p</code></td>
    <td><code>:p</code></td>
    <td><code>"x"</code></td>
    <td><code>"p"</code></td>
  </tr>
</table>

Case - Value interpolation:

```julia
q=:p  # Main.q
p=7   # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@quo 2</code></td>
    <td><code>@quo 2 + 2</code></td>
    <td><code>@quo 2 + $(sin(1))</code></td>
    <td><code>@quo 2 + $q</code></td>
    <td><code>eval(@quo 2 + $q)</code></td>
  </tr>
  <tr>
    <td><code>macro quo(ex)
 :(x=$(esc(ex));
   :($x+$x))
end</code></td>
    <td><code>:(2 + 2)</code></td>
    <td><code>:(4 + 4)</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro quo(ex)
 :(x=$(quot(ex));
   :($x+$x))
end</code></td>
    <td><code>:(2 + 2)</code></td>
    <td><code>:((2 + 2) + (2 + 2))</code></td>
    <td><code>:((2 + 0.8414709848078965) + (2 + 0.8414709848078965))</code></td>
    <td><code>:((2 + p) + (2 + p))</code></td>
    <td><code>18</code></td>
  </tr>
  <tr>
    <td><code>macro quo(ex)
 :(x=$(QuoteNode(ex));
   :($x+$x))
end</code></td>
    <td><code>:(2 + 2)</code></td>
    <td><code>:((2 + 2) + (2 + 2))</code></td>
    <td><code>:((2 + $(Expr(:$, :(sin(1))))) + (2 + $(Expr(:$, :(sin(1))))))</code></td>
    <td><code>:((2 + $(Expr(:$, :q))) + (2 + $(Expr(:$, :q))))</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
</table>

Case - Expression interpolation:

```julia
ex=:ey   #  Main.ex
x=:p     #  Main.x
p=7      #  Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym x)</code></td>
    <td><code>@macroexpand(@sym $x)</code></td>
    <td><code>@sym x</code></td>
    <td><code>eval(@sym x)</code></td>
    <td><code>@sym $x</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 ex
end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:($(Expr(:$, :(Main.x))))</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(ex)
end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>:ey</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($ex)
end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:($(Expr(:$, :(Main.x))))</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($:($ex))
end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:($(Expr(:$, :(Main.x))))</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(quot($ex))
end</code></td>
    <td><code>:(Main.quot(Main.x))</code></td>
    <td><code>:(Main.quot($(Expr(:$, :(Main.x)))))</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 QuoteNode(ex)
end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:($(QuoteNode(:($(Expr(:$, :x))))))</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>:($(Expr(:$, :x)))</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(QuoteNode($ex))
end</code></td>
    <td><code>:(Main.QuoteNode(Main.x))</code></td>
    <td><code>:(Main.QuoteNode($(Expr(:$, :(Main.x)))))</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($(QuoteNode(ex)))
end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:($(QuoteNode(:($(Expr(:$, :x))))))</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>:($(Expr(:$, :x)))</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote 
 QuoteNode($ex)
end; end</code></td>
    <td><code>quote
    Main.QuoteNode(Main.x)
end</code></td>
    <td><code>quote
    Main.QuoteNode($(Expr(:$, :(Main.x))))
end</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote
 $(QuoteNode(ex))
end; end</code></td>
    <td><code>quote
    :x
end</code></td>
    <td><code>quote
    $(QuoteNode(:($(Expr(:$, :x)))))
end</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>:($(Expr(:$, :x)))</code></td>
  </tr>
</table>

Case - Advanced expression interpolation  (note: @ip: interpolation, l: left, r: r):

<table>
  <tr>
    <td></td>
    <td><code>@ip y=1 y y</code></td>
    <td><code>eval(@ip y=1 y y)</code></td>
    <td><code>eval(eval(@ip y=1 y y))</code></td>
    <td><code>@ip y=1 y/2 y</code></td>
    <td><code>eval(@ip y=1 y/2 y)</code></td>
    <td><code>@ip y=1 1/2 1/4</code></td>
    <td><code>eval(@ip y=1 1/2 1/4)</code></td>
    <td><code>@ip y=1 $y $y</code></td>
    <td><code>eval(@ip y=1 1+$y $y)</code></td>
    <td><code>@ip y=1 $y/2 $y</code></td>
    <td><code>eval(@ip y=1 $y/2 $y)</code></td>
  </tr>
  <tr>
    <td><code>macro ip(ex, l, r)
quote
 Meta.quot($ex)
 :($$(Meta.quot(l)) + $$(Meta.quot(r)))
end
end</code></td>
    <td><code>:(y + y)</code></td>
    <td><code>MethodError: +(:p, :p)</code></td>
    <td><code>MethodError: +(:p, :p)</code></td>
    <td><code>:(y / 2 + y)</code></td>
    <td><code>MethodError: /(:p, 2)</code></td>
    <td><code>:(1 / 2 + 1 / 4)</code></td>
    <td><code>0.75</code></td>
    <td><code>:(1 + 1)</code></td>
    <td><code>3</code></td>
    <td><code>:(1 / 2 + 1)</code></td>
    <td><code>1.5</code></td>
  </tr>
  <tr>
    <td><code>macro ip(ex, l, r)
quote
 $(Meta.quot(ex))
 :($$(Meta.quot(l)) + $$(Meta.quot(r)))
 end
end</code></td>
    <td><code>:(y + y)</code></td>
    <td><code>MethodError: +(:p, :p)</code></td>
    <td><code>MethodError: +(:p, :p)</code></td>
    <td><code>:(y / 2 + y)</code></td>
    <td><code>MethodError: /(:p, 2)</code></td>
    <td><code>:(1 / 2 + 1 / 4)</code></td>
    <td><code>0.75</code></td>
    <td><code>:(p + p)</code></td>
    <td><code>15</code></td>
    <td><code>:(p / 2 + p)</code></td>
    <td><code>10.5</code></td>
  </tr>
  <tr>
    <td><code>macro ip(ex, l, r)
quote
 quote
  $$(Meta.quot(ex))
  :($$$(Meta.quot(l)) + $$$(Meta.quot(r)))
 end
end
end</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :y)) + $(Expr(:$, :y)))))
end</code></td>
    <td><code>:(1 + 1)</code></td>
    <td><code>2</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(y / 2))) + $(Expr(:$, :y)))))
end</code></td>
    <td><code>:(0.5 + 1)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, :(1 / 4))))))
end</code></td>
    <td><code>:(0.5 + 0.25)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, 1)) + $(Expr(:$, 1)))))
end</code></td>
    <td><code>:(2 + 1)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, 1)))))
end</code></td>
    <td><code>:(0.5 + 1)</code></td>
  </tr>
  <tr>
    <td><code>macro ip(ex, l, r)
quote
 quote
  $$(Meta.quot(ex))
  :($$$(Meta.quot(l)) + $$$(Meta.quot(r)))
 end
end
end</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :y)) + $(Expr(:$, :y)))))
end</code></td>
    <td><code>:(1 + 1)</code></td>
    <td><code>2</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(y / 2))) + $(Expr(:$, :y)))))
end</code></td>
    <td><code>:(0.5 + 1)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, :(1 / 4))))))
end</code></td>
    <td><code>:(0.5 + 0.25)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, 1)) + $(Expr(:$, 1)))))
end</code></td>
    <td><code>:(2 + 1)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, 1)))))
end</code></td>
    <td><code>:(0.5 + 1)</code></td>
  </tr>
  <tr>
    <td><code>macro ip(ex, l, r)
quote
 quote
  $$(Meta.quot(ex))
  :($$(Meta.quot($(Meta.quot(l)))) + $$(Meta.quot($(Meta.quot(r)))))
 end
end
end</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(:y))) + $(Expr(:$, :(:y))))))
end</code></td>
    <td><code>:(y + y)</code></td>
    <td><code>2</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(y / 2)))))) + $(Expr(:$, :(:y))))))
end</code></td>
    <td><code>:(y / 2 + y)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, :(1 / 4)))))))))
end</code></td>
    <td><code>:(1 / 2 + 1 / 4)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, 1))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</code></td>
    <td><code>:((1 + 1) + 1)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</code></td>
    <td><code>:(1 / 2 + 1)</code></td>
  </tr>
  <tr>
    <td><code>macro ip(ex, l, r)
quote
 quote
  $$(Meta.quot(ex))
  :($$(Meta.quot($(QuoteNode(l)))) + $$(Meta.quot($(QuoteNode(r)))))
 end
end
end</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :(:y))) + $(Expr(:$, :(:y))))))
end</code></td>
    <td><code>:(y + y)</code></td>
    <td><code>2</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(y / 2)))))) + $(Expr(:$, :(:y))))))
end</code></td>
    <td><code>:(y / 2 + y)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, :(1 / 4)))))))))
end</code></td>
    <td><code>:(1 / 2 + 1 / 4)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :y)))))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :y)))))))))))
end</code></td>
    <td><code>:((1 + 1) + 1)</code></td>
    <td><code>quote
    y = 1
    $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :y)) / 2)))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :y)))))))))))
end</code></td>
    <td><code>:(1 / 2 + 1)</code></td>
  </tr>
</table>
Sources: https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-