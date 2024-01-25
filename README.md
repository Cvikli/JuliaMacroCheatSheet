```julia
q=:p
p=7
```
<table>
  <tr>
    <td></td>
    <td><code>@quo 2</code></td>
    <td><code>@quo 2 + 2</code></td>
    <td><code>@quo 2 + $(sin(1))</code></td>
    <td><code>@quo 2 + $q</code></td>
    <td><code>eval(@quo 2 + $q)</code></td>
  </tr>
  <tr>
    <td><code>macro quo(ex)
 :( x = $(esc(ex)); :($x + $x) )
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro quo(ex)
 :( x = $(quot(ex)); :($x + $x) )
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro quo(ex)
 :( x = $(QuoteNode(ex)); :($x + $x) )
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
</table>
```julia
x=:p  # Main.x
p=8   # Main.p
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
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(x); end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(:x); end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(x); end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(:x); end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(); QuoteNode(:x); end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
</table>
```julia
ex=:ey   #  Main.exy=:p     #  Main.yp=8      #  Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@sym y)</code></td>
    <td><code>@macroexpand(@sym $y)</code></td>
    <td><code>@sym y</code></td>
    <td><code>eval(@sym y)</code></td>
    <td><code>@sym $y</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 ex
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(ex)
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>UndefVarError(:ey)</code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($ex)
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($:($ex))
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(quot($ex))
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 QuoteNode(ex)
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(QuoteNode($ex))
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($(QuoteNode(ex)))
end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote 
 QuoteNode($ex)
end; end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote
 $(QuoteNode(ex))
end; end</code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
    <td><code></code></td>
  </tr>
</table>
