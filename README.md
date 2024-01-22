# JuliaMacroCheatSheet
Macro CheatSheet

$\color{rgb(255,0,0)}{\textsf{lorem ipsum}}$

<style>
tr:nth-child(even) {
  background-color: #b200b2!important;
  color: #f4f4f4!important;
}
</style>


<table>
  <tr align="left"> <!-- HEADER -->
    <th><code>var="ok"
fn(var) && @fn var</code></th>
    <th><code>function f(ex)
 ...
end</code></th>
    <!-- <th><code>function f(ex)
 quote
  ...
 end
end</code></th> -->
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
    <td>“ok”</td>
    <!-- <td>quote<br>
 #= ~/macro.jl:41 =#<br>
 println(ex)<br>
end</td> -->
    <td>var</td>
    <td>ERROR: UndefVarError: `ex` not defined<br>
If ex is defined in scope then we get the “value of ex”</td>
    <td>ERROR: UndefVarError: `ex` not defined<br>
If ex is defined in scope then we get the “value of ex”</td>
  </tr>


  <tr align="left"><!-- ROW 2 -->
    <td><code>println($(ex))</code></td>
    <td>Compilation error</td>
    <!-- <td>quote<br>
 #= ~/macro.jl.jl:16 =#<br>
 println("ok")<br>
end</td> -->
    <td>Compilation error</td>
    <td>“ok”</td>
    <td>“ok”</td>
  </tr>


  <tr align="left"><!-- ROW 3 -->
    <td><code>println($(esc(ex)))</code></td>
    <td>Compilation error</td>
    <!-- <td>quote<br>
 #= ~/macro.jl.jl:21 =#<br>
 println($(Expr(:escape, "ok")))<br>
end</td> -->
    <td>Compilation error</td>
    <td>“ok”</td>
    <td>“ok”</td>
  </tr>


  <tr align="left"><!-- ROW 4 -->
    <td><code>println($(string(ex)))</code></td>
    <td>Compilation error</td>
    <!-- <td>quote<br>
 #= ~/macro.jl.jl:31 =#<br>
 ss = gensym()<br>
 #= ~/macro.jl.jl:32 =#<br>
 println(ss)<br>
end</td> -->
    <td>Compilation error</td>
    <td>var</td>
    <td>var</td>
  </tr>


  <tr align="left"><!-- ROW 5 -->
    <td><code>println(gensym())</code></td>
    <td>##225 (generated the next variable symbol)</td>
    <!-- <td>quote<br>
 #= ~/macro.jl.jl:26 =#<br>
 println(gensym())<br>
end</td> -->
    <td>##226 (generated the next variable symbol)</td>
    <td>##227 (generated the next variable symbol)</td>
    <td>##228 (generated the next variable symbol)</td>
  </tr>


  <tr align="left"><!-- ROW 6 -->
    <td><code>ss=gensym()
println(ss)</code></td>
    <td>Printed: var”##230”</td>
    <!-- <td>quote<br>
 #= ~/macro.jl.jl:31 =#<br>
 ss = gensym()<br>
 #= ~/macro.jl.jl:32 =#<br>
 println(ss)<br>
end</td> -->
    <td>Printed: var”##231”</td>
    <td>Ununderstandable case (as multiline expression…) </td>
    <td>Printed: var”##232”<br>
Created: var"#138#ss"</td>
  </tr>
</table>













