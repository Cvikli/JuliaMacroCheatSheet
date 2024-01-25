```julia
q=:p  # Main.q
p=7   # Main.p
```
<table>
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
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>8</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(x); end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>8</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); :(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(x); end</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>8</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); quot(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
  </tr>
  <tr>
    <td><code>macro sym(); QuoteNode(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
  </tr>
</table>
```julia
ex=:ey   #  Main.ex
y=:p     #  Main.y
p=8      #  Main.p
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
    <td><code>:(Main.y)</code></td>
    <td><code>:($(Expr(:$, :(Main.y))))</code></td>
    <td><code>:p</code></td>
    <td><code>8</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(ex)
end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>UndefVarError(:ey)</code></td>
    <td><code>:ey</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($ex)
end</code></td>
    <td><code>:(Main.y)</code></td>
    <td><code>:($(Expr(:$, :(Main.y))))</code></td>
    <td><code>:p</code></td>
    <td><code>8</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($:($ex))
end</code></td>
    <td><code>:(Main.y)</code></td>
    <td><code>:($(Expr(:$, :(Main.y))))</code></td>
    <td><code>:p</code></td>
    <td><code>8</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(quot($ex))
end</code></td>
    <td><code>:(Main.quot(Main.y))</code></td>
    <td><code>:(Main.quot($(Expr(:$, :(Main.y)))))</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 QuoteNode(ex)
end</code></td>
    <td><code>:(:y)</code></td>
    <td><code>:($(QuoteNode(:($(Expr(:$, :y))))))</code></td>
    <td><code>:y</code></td>
    <td><code>:p</code></td>
    <td><code>:($(Expr(:$, :y)))</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :(QuoteNode($ex))
end</code></td>
    <td><code>:(Main.QuoteNode(Main.y))</code></td>
    <td><code>:(Main.QuoteNode($(Expr(:$, :(Main.y)))))</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>syntax: "$" expression outside quote</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex)
 :($(QuoteNode(ex)))
end</code></td>
    <td><code>:(:y)</code></td>
    <td><code>:($(QuoteNode(:($(Expr(:$, :y))))))</code></td>
    <td><code>:y</code></td>
    <td><code>:p</code></td>
    <td><code>:($(Expr(:$, :y)))</code></td>
  </tr>
  <tr>
    <td><code>macro sym(ex); quote 
 QuoteNode($ex)
end; end</code></td>
    <td><code>quote
    #= none:2 =#
    Main.QuoteNode(Main.y)
end</code></td>
    <td><code>quote
    #= none:2 =#
    Main.QuoteNode($(Expr(:$, :(Main.y))))
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
    #= none:2 =#
    :y
end</code></td>
    <td><code>quote
    #= none:2 =#
    $(QuoteNode(:($(Expr(:$, :y)))))
end</code></td>
    <td><code>:y</code></td>
    <td><code>:p</code></td>
    <td><code>:($(Expr(:$, :y)))</code></td>
  </tr>
</table>
