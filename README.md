
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
    <th><code>fn(sleep(1))</code> or <code>@fn sleep(1)</code></th>
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




