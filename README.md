
<style>
body {
  background: #333!important;
  color: #f4f4f4!important;
}
</style>

# JuliaMacroCheatSheet
Macro CheatSheet

Calling function or macro behavior can be different: `fn(var) or @fn var`
`Meta.quot(x)` equal with `Expr(:quote, x)` (Macro hygenie does not apply... so no `esc` required)
Similar: `QuoteNode(c)` but prevents interpolation. So if `$`(literal) is in the args, it won't interpolate, just "will be interpolated when evaluated".


Note: Linenumbers are removed from the CheatSheet!

Case - variable in Main module:
```julia
var="ok"
```
<table>
  <tr align="left"> <!-- HEADER -->
    <th><code>fn(var)</code> or <code>@fn var</code></th>
    <th><code>function f(ex)
 ...
end</code></th>
    <th><code>macro f(ex)
 ...
end</code></th>
  <th><code>macro f(ex)
 :(...)
end</code></th>
<th><code>macro f(ex)
 quote
  ...
 end
end</code></th>
  </tr>

  <tr align="left"> <!-- ROW 1 -->
    <td><code>println(ex)</code></td>
    <td style="background-color: #2f2; color: #222">"ok”</td>
    <td style="background-color: #2f2; color: #222">var</td>
    <td style="background-color: #ff2; color: #222">ERROR: `ex` not defined (hygenie)</td>
    <td style="background-color: #ff2; color: #222">ERROR: `ex` not defined (hygenie)</td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>println($(ex))</code></td>
    <td style="background-color: #e55; color: #222">Compilation error</td>
    <td style="background-color: #e55; color: #222">Compilation error</td>
    <td style="background-color: #ff2; color: #222">“ok”</td>
    <td style="background-color: #ff2; color: #222">“ok”</td>
  </tr>
  <tr align="left"><!-- ROW 3 -->
    <td><code>println($(esc(ex)))</code></td>
    <td style="background-color: #e55; color: #222">Compilation error</td>
    <td style="background-color: #e55; color: #222">Compilation error</td>
    <td style="background-color: #2f2; color: #222">“ok”</td>
    <td style="background-color: #2f2; color: #222">“ok”</td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>println($(string(ex)))</code></td>
    <td style="background-color: #e55; color: #222">Compilation error</td>
    <td style="background-color: #e55; color: #222">Compilation error</td>
    <td style="background-color: #2f2; color: #222">var</td>
    <td style="background-color: #2f2; color: #222">var</td>
  </tr>

</table>



Case - Expression evaluation:
<table>
  <tr align="left"> <!-- HEADER -->
    <th></th>
    <th><code>macro quo(arg)
 :( x = $(esc(arg)); :($x + $x) )
end</code></th>
    <th><code>macro quo(arg)
 :( x = $(Meta.quot(arg)); :($x + $x) )
end</code></th>
  <th><code>macro quo(arg)
 :( x = $(QuoteNode(arg)); :($x + $x) )
end</code></th>

  </tr>

  
  <tr align="left"> <!-- ROW 1 -->
    <td><code>@quo 1</code></td>
    <td style="background-color: #2f2; color: #222">:(1 + 1)</td>
    <td style="background-color: #2f2; color: #222">:(1 + 1)</td>
    <td style="background-color: #ff2; color: #222">:(1 + 1)</td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>@quo 1 + 1</code></td>
    <td style="background-color: #e55; color: #222">:(2 + 2)</td>
    <td style="background-color: #e55; color: #222">:((1 + 1) + (1 + 1))</td>
    <td style="background-color: #ff2; color: #222">:((1 + 1) + (1 + 1))</td>
  </tr>
  <tr align="left"><!-- ROW 3 -->
    <td><code>@quo 1 + $(sin(1))</code></td>
    <td style="background-color: #e55; color: #222">ERROR: "$" expression outside quote</td>
    <td style="background-color: #e55; color: #222">:((1 + 0.84147…) + (1 + 0.841…))</td>
    <td style="background-color: #2f2; color: #222">:((1 + $(Expr(:$, :(sin(1))))) + (1 + $(Expr(:$, :(sin(1))))))</td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>let q = 0.5 
 @quo 1 + $q
end</code></td>
    <td style="background-color: #e55; color: #222">ERROR: "$" expression outside quote</td>
    <td style="background-color: #e55; color: #222">ERROR: UndefVarError: `q` not defined</td>
    <td style="background-color: #2f2; color: #222">:((1 + $(Expr(:$, :q))) + (1 + $(Expr(:$, :q))))</td>
  </tr>

</table>



Case - Expression interpolation (@ip):
<table>
  <tr align="left"> <!-- HEADER -->
    <th>________________________</th>
    <th><code>macro ip(expr, left, right)
 quote
  Meta.quot($expr)
  :($$(Meta.quot(left)) + $$(Meta.quot(right)))
 end
end
_____________________________________________</code></th>
    <th><code>macro ip(expr, left, right)
 quote
  $(Meta.quot(expr))
    :($$(Meta.quot(left)) + $$(Meta.quot(right)))
  end
end
_______________________________________</code></th>
  <th><code>macro ip(expr, left, right)
 quote
  quote
   $$(Meta.quot(expr))
   :($$$(Meta.quot(left)) + $$$(Meta.quot(right)))
  end
 end
end
________________________________________________</code></th>
<th><code>macro ip(expr, left, right)
 quote
  quote
   $$(Meta.quot(expr))
   :($$(Meta.quot($(Meta.quot(left)))) + $$(Meta.quot($(Meta.quot(right)))))
  end
 end
end
____________________________________________________________</code></th>
<th><code>macro ip(expr, left, right)
 quote
  quote
   $$(Meta.quot(expr))
   :($$(Meta.quot($(QuoteNode(left)))) + $$(Meta.quot($(QuoteNode(right)))))
  end
 end
end
_______________________________________________________________________</code></th>
  </tr>
  <tr align="left"><!-- ROW 1 -->
    <td><code>@ip x=1 x x</code></td>
    <td style="background-color: #2f2; color: #222">:(x + x)</td>
    <td style="background-color: #2f2; color: #222">:(x + x)</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :x)) + $(Expr(:$, :x)))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(:x))) + $(Expr(:$, :(:x))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(:x))) + $(Expr(:$, :(:x))))))
end</td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>eval(@ip x=1 x x)</code></td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #e55; color: #222">:(1+1)</td>
    <td style="background-color: #e55; color: #222">:(x + x)</td>
    <td style="background-color: #e55; color: #222">:(x + x)</td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>eval(eval(@ip x=1 x x))</code></td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #e55; color: #222">2</td>
    <td style="background-color: #e55; color: #222">2</td>
    <td style="background-color: #e55; color: #222">2</td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>@ip x=1 x/2 x</code></td>
    <td style="background-color: #2f2; color: #222">:(x / 2 + x)</td>
    <td style="background-color: #2f2; color: #222">:(x / 2 + x)</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(x / 2))) + $(Expr(:$, :x)))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(x / 2)))))) + $(Expr(:$, :(:x))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(x / 2)))))) + $(Expr(:$, :(:x))))))
end</td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>eval(@ip x=1 x/2 x)</code></td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #e55; color: #222">:(0.5 + 1)</td>
    <td style="background-color: #e55; color: #222">:(x / 2 + x)</td>
    <td style="background-color: #e55; color: #222">:(x / 2 + x)</td>
  </tr>
  <tr align="left"><!-- ROW 3 -->
    <td><code>@ip x=1 1/2 1/4</code></td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1 / 4)</td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1 / 4)</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, :(1 / 4))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, :(1 / 4)))))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, :(1 / 4)))))))))
end</td>
  </tr>
  <tr align="left"><!-- ROW 3 -->
    <td><code>eval(@ip x=1 1/2 1/4)</code></td>
    <td style="background-color: #2f2; color: #222">0.75</td>
    <td style="background-color: #2f2; color: #222">0.75</td>
    <td style="background-color: #2f2; color: #222">:(0.5 + 0.25)</td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1 / 4)</td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1 / 4)</td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>@ip x=1 $x $x</code></td>
    <td style="background-color: #2f2; color: #222">:(1 + 1)</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, 1)) + $(Expr(:$, 1)))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, 1))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))))))
end</td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>eval(@ip x=1 $x $x)</code></td>
    <td style="background-color: #2f2; color: #222">2</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #2f2; color: #222">:(1 + 1)</td>
    <td style="background-color: #2f2; color: #222">:(1 + 1)</td>
    <td style="background-color: #2f2; color: #222">:(1 + 1)</td>
  </tr>
  <tr align="left"><!-- ROW 6 -->
    <td><code>@ip x=1 1+$x $x</code></td>
    <td style="background-color: #2f2; color: #222">:((1 + 1) + 1)</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(1 + 1))) + $(Expr(:$, 1)))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 + 1)))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 + $(Expr(:$, :x)))))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))))))
end</td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>eval(@ip x=1 1+$x $x)</code></td>
    <td style="background-color: #2f2; color: #222">3</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #2f2; color: #222">:(2 + 1)</td>
    <td style="background-color: #2f2; color: #222">:((1 + 1) + 1)</td>
    <td style="background-color: #2f2; color: #222">:((1 + 1) + 1)</td>
  </tr>
  <tr align="left"><!-- ROW 7 -->
    <td><code>@ip x=1 $x/2 $x</code></td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1)</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, 1)))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</td>
    <td style="background-color: #2f2; color: #222">quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)) / 2)))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))))))
end</td>
  </tr>
  <tr align="left"><!-- ROW 7 -->
    <td><code>eval(@ip x=1 $x/2 $x)</code></td>
    <td style="background-color: #2f2; color: #222">1.5</td>
    <td style="background-color: #e55; color: #222">Error: `x` not defined</td>
    <td style="background-color: #2f2; color: #222">:(0.5 + 1)</td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1)</td>
    <td style="background-color: #2f2; color: #222">:(1 / 2 + 1)</td>
  </tr>
</table>

Case - generate variable:
```julia
gensym()
```
<table>
  <tr align="left"> <!-- HEADER -->
    <th><code>fn(var)</code> or <code>@fn var</th>
    <th><code>function f(ex)
 ...
end</code></th>
    <th><code>macro f(ex)
  ...
end</code></th>
  <th><code>macro f(ex)
 :(...)
end</code></th>
<th><code>macro f(ex)
 quote
  ...
 end
end</code></th>
  </tr>
  <tr align="left"><!-- ROW 5 -->
    <td><code>println(gensym())</code></td>
    <td>##225 (generated the next variable symbol)</td>
    <td>##226 (generated the next variable symbol)</td>
    <td>##227 (generated the next variable symbol)</td>
    <td>##228 (generated the next variable symbol)</td>
  </tr>


  <tr align="left"><!-- ROW 6 -->
    <td><code>ss=gensym()
println(ss)</code></td>
    <td>Printed: var”##230”</td>
    <td>Printed: var”##231”</td>
    <td>Printed: var”##232”</td>
    <td>Printed: var”##233”<br>
Created: var"#138#ss"</td>
  </tr>
</table>






Sources: https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-expr--quote-



