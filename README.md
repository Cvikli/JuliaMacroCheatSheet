
<style>
body {
  background: #333!important;
  color: #f4f4f4!important;
}
</style>

# JuliaMacroCheatSheet
Macro CheatSheet

Calling function or macro behavior can be different: `fn(var) or @fn var`


Note: Linenumbers are removed from the CheatSheet!
All test has included: `using Base.Meta: quot, QuoteNode`


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
```julia
p=8
x=:p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym)</code></td>
    <td><code>@sym</code></td>
    <td><code>eval(@sym)</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :x; end</code></td>
    <td><code>Main.x</code></td>
    <td><code>p</code></td>
    <td><code>8</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(x); end</code></td>
    <td><code>Main.x</code></td>
    <td><code>p</code></td>
    <td><code>8</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(:x); end</code></td>
    <td><code>:x</code></td>
    <td><code>x</code></td>
    <td><code>p</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(x); end</code></td>
    <td><code>:p</code></td>
    <td><code>p</code></td>
    <td><code>8</code></td>
  </tr>
  <tr>
  <td><code>macro sym(); quot(:x); end</code></td>
    <td><code>:x</code></td>
    <td><code>x</code></td>
    <td><code>p</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); QuoteNode(:x); end</code></td>
    <td><code>:x</code></td>
    <td><code>x</code></td>
    <td><code>p</code></td>
  </tr>
</table>

```julia
using Base.Meta: quot, QuoteNode
ex=:ey
y=:p
p=8
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym y)</code></td>
    <td><code>@macroexpand(@sym $y)</code></td>
    <td><code>@sym y</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); :($ex); end</code></td>
    <td><code>Main.y</code></td>
    <td><code>$Main.y</code></td>
    <td><code>p</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); :(:($ex)); end</code></td>
    <td><code>Main.ex</code></td>
    <td><code>Main.ex</code></td>
    <td><code>ey</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex) 
  :(quot($ex))
end</code></td>
    <td><code>Main.quot(Main.y)</code></td>
    <td><code>Main.quot($Main.y)</code></td>
    <td><code>:p</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
  :(QuoteNode($ex))
end</code></td>
    <td><code>Main.QuoteNode(Main.y)</code></td>
    <td><code>Main.QuoteNode($Main.y)</code></td>
    <td><code>:p</code></td>
  </tr>
</table>



<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym y)</code></td>
    <td><code>@macroexpand(@sym $y)</code></td>
    <td><code>@sym y</code></td>
    <td><code>@sym $y</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); QuoteNode(ex); end</code></td>
    <td><code>:y</code></td>
    <td><code>$(QuoteNode(:($(Expr(:$, :y)))))</code></td>
    <td><code>y</code></td>
    <td><code>$y</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); :(QuoteNode($ex)); end</code></td>
    <td><code>Main.QuoteNode(Main.y)</code></td>
    <td><code>Main.QuoteNode($Main.y)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); :($QuoteNode(ex)); end</code></td>
    <td><code>(QuoteNode)(Main.ex)</code></td>
    <td><code>(QuoteNode)(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); :($QuoteNode($ex)); end</code></td>
    <td><code>(QuoteNode)(Main.y)</code></td>
    <td><code>(QuoteNode)($Main.y)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote (QuoteNode($ex)); end; end</code></td>
    <td><code>begin
  Main.QuoteNode(Main.y)
end</code></td>
    <td><code>begin
  Main.QuoteNode($Main.y)
end</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote ($QuoteNode(ex)); end; end</code></td>
    <td><code>begin
  (QuoteNode)(Main.ex)
end</code></td>
    <td><code>begin
  (QuoteNode)(Main.ex)
end</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote ($QuoteNode($ex)); end; end</code></td>
    <td><code>begin
  (QuoteNode)(Main.y)
end</code></td>
    <td><code>begin
  (QuoteNode)($Main.y)
end</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
</table>



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


`Meta.quot(x)` equal with `Expr(:quote, x)` (Macro hygenie does not apply... so no `esc` required)
Similar: `QuoteNode(c)` but prevents interpolation. So if `$`(literal) is in the args, it won't interpolate, just "will be interpolated when evaluated".
Difference between Meta.quot() and QuoteNode() is the interpolation.

Advanced: 
Case - Expression interpolation (@ip, note: l=left, r=r):
<table>
  <tr align="left"> <!-- HEADER -->
    <th>_______________________</th>
    <th><code>macro ip(ex, l, r)
 quote
  Meta.quot($ex)
  :($$(Meta.quot(l)) + $$(Meta.quot(r)))
 end
end</code>
_______________________</th>
    <th><code>macro ip(ex, l, r)
 quote
  $(Meta.quot(ex))
    :($$(Meta.quot(l)) + $$(Meta.quot(r)))
  end
end
</code>
________________________</th>
  <th><code>macro ip(ex, l, r)
 quote
  quote
   $$(Meta.quot(ex))
   :($$$(Meta.quot(l)) + $$$(Meta.quot(r)))
  end
 end
end
</code>
_________________________</th>
<th><code>macro ip(ex, l, r)
 quote
  quote
   $$(Meta.quot(ex))
   :($$(Meta.quot($(Meta.quot(l)))) + $$(Meta.quot($(Meta.quot(r)))))
  end
 end
end
</code>
____________________________________</th>
<th><code>macro ip(ex, l, r)
 quote
  quote
   $$(Meta.quot(ex))
   :($$(Meta.quot($(QuoteNode(l)))) + $$(Meta.quot($(QuoteNode(r)))))
  end
 end
end
</code>
_____________________________________</th>
  </tr>
  <tr align="left"><!-- ROW 1 -->
    <td><code>@ip x=1 x x</code></td>
    <td style="background-color: #2f2; color: #222">:(x + x)</td>
    <td style="background-color: #2f2; color: #222">:(x + x)</td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :x)) + $(Expr(:$, :x)))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(:x))) + $(Expr(:$, :(:x))))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(:x))) + $(Expr(:$, :(:x))))))
end</code></td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>eval(@ip x=1 x x)</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #e55; color: #222"><code>:(1+1)</code></td>
    <td style="background-color: #e55; color: #222"><code>:(x + x)</code></td>
    <td style="background-color: #e55; color: #222"><code>:(x + x)</code></td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>eval(eval(@ip x=1 x x))</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #e55; color: #222"><code>2</code></td>
    <td style="background-color: #e55; color: #222"><code>2</code></td>
    <td style="background-color: #e55; color: #222"><code>2</code></td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>@ip x=1 x/2 x</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(x / 2 + x)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(x / 2 + x)</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(x / 2))) + $(Expr(:$, :x)))))
end<code></td>
    <td style="background-color: #2f2; color: #222"></code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(x / 2)))))) + $(Expr(:$, :(:x))))))
end<code></td>
    <td style="background-color: #2f2; color: #222"></code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(x / 2)))))) + $(Expr(:$, :(:x))))))
end</code></td>
  </tr>
  <tr align="left"><!-- ROW 2 -->
    <td><code>eval(@ip x=1 x/2 x)</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined<code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined<code></td>
    <td style="background-color: #e55; color: #222"><code>:(0.5 + 1)<code></td>
    <td style="background-color: #e55; color: #222"><code>:(x / 2 + x)<code></td>
    <td style="background-color: #e55; color: #222"><code>:(x / 2 + x)<code></td>
  </tr>
  <tr align="left"><!-- ROW 3 -->
    <td><code>@ip x=1 1/2 1/4</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1 / 4)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1 / 4)</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, :(1 / 4))))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, :(1 / 4)))))))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, :(1 / 4)))))))))
end</code></td>
  </tr>
  <tr align="left"><!-- ROW 3 -->
    <td><code>eval(@ip x=1 1/2 1/4)</code></td>
    <td style="background-color: #2f2; color: #222"><code>0.75</code></td>
    <td style="background-color: #2f2; color: #222"><code>0.75</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(0.5 + 0.25)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1 / 4)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1 / 4)</code></td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>@ip x=1 $x $x</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 + 1)</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, 1)) + $(Expr(:$, 1)))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, 1))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))))))
end</code></td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>eval(@ip x=1 $x $x)</code></td>
    <td style="background-color: #2f2; color: #222"><code>2</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 + 1)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 + 1)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 + 1)</code></td>
  </tr>
  <tr align="left"><!-- ROW 6 -->
    <td><code>@ip x=1 1+$x $x</code></td>
    <td style="background-color: #2f2; color: #222"><code>:((1 + 1) + 1)</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(1 + 1))) + $(Expr(:$, 1)))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 + 1)))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 + $(Expr(:$, :x)))))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))))))
end</code></td>
  </tr>
  <tr align="left"><!-- ROW 4 -->
    <td><code>eval(@ip x=1 1+$x $x)</code></td>
    <td style="background-color: #2f2; color: #222"><code>3</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(2 + 1)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:((1 + 1) + 1)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:((1 + 1) + 1)</code></td>
  </tr>
  <tr align="left"><!-- ROW 7 -->
    <td><code>@ip x=1 $x/2 $x</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1)</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :(1 / 2))) + $(Expr(:$, 1)))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :(1 / 2)))))) + $(Expr(:$, :($(Expr(:quote, 1))))))))
end</code></td>
    <td style="background-color: #2f2; color: #222"><code>quote
 x = 1
 $(Expr(:quote, :($(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)) / 2)))))) + $(Expr(:$, :($(Expr(:quote, :($(Expr(:$, :x)))))))))))
end</code></td>
  </tr>
  <tr align="left"><!-- ROW 7 -->
    <td><code>eval(@ip x=1 $x/2 $x)</code></td>
    <td style="background-color: #2f2; color: #222"><code>1.5</code></td>
    <td style="background-color: #e55; color: #222"><code>Error: `x` not defined</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(0.5 + 1)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1)</code></td>
    <td style="background-color: #2f2; color: #222"><code>:(1 / 2 + 1)</code></td>
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






Sources: https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-



