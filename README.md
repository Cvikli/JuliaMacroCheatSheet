# Julia Macro CheatSheet

The whole file is wider on this screen: https://github.com/Cvikli/JuliaMacroCheatSheet/blob/main/README.md

For me https://docs.julialang.org/en/v1/manual/metaprogramming/ just couldn't make these things understand so I tried to be as short as possible to reach understanding in each point. n
Please help us correct things and any simplification is welcomed, It is still a little bit too complicated I know, this have to be even shorter.! 

## Macro hygiene (aka: SCOPE management)
In short: Escape: = "Access the local scope from where the macro is called!"
In macro hygiene, each interpolated variable(`VAR`) in the macro points to `Main.VAR` instead of the local `VAR` in the macro's calling scope. 
```julia
a=1
macro ✖();    :($:a); end        
eval(let a=2; :($a);  end)        # =2  (exactly the same like: (`let a=2; a; end`))
     let a=2; @✖();   end          # =1
macro ✓();    :($(esc(:a))); end   
eval(let a=2; :($(esc(:a))); end) # ERROR: syntax: invalid syntax (escape (outerref a))
     let a=2; @✓();          end   # =2
```
BUT it generates new variable for the macro scope instead of the "local" scope. So eventually it doesn't see the outer scope variables in this case and believe this is the "new scope where the expression has to work".
```
a=1
macro ✖(ex); :($ex); end         
macro ✓(ex); :($(esc(ex))); end   # this works similarly: `:(:ey)`
eval(        :(a=2))               # a=2
# eval(        :($(esc(a=3))))    # ERROR: MethodError: no method matching esc(; b::Int64)
@✖ a=4                             # a=2
@✓ a=5                             # a=5
display(@macroexpand @✖ a=4)       # :(var"#54#a" = 4)
display(@macroexpand @✓ a=5)       # :(a = 5)
```
also
```
macro ✖(va, ex); :($va=$ex); end 
macro ✓(va, ex); :($(esc(va))=$(esc(ex))); end 
@✖ a 5
@✓ a 6
display(@macroexpand @✖ a 5)
display(@macroexpand @✓ a 6)
```
First we work in the macro scope, so it shadows(`gensym(:a)`) the variable. We need to use `esc` to reach the local scope. 

## Reducing redundancy
```
quote 2+3 end == :(begin 2+3 end)  # both preserve the linenumbers (verifiable with `dump(…)`)
:(2+3)                             # also similar but without FIRST Linenumber
```
## Evaluation time
`$` (expression interpolation) evaluates when the expression is constructed (at parse time)

`:` or `quote` … `end`(Quotations) evaluates only when the expression is passed to eval at runtime.

## Learning/repeating knowledge from tests

Note: 
- All test has included `using Base.Meta: quot, QuoteNode`.
- Linenumbers are removed from the CheatSheet!


### Case - Basic expressions:

```julia
x=:p   # Main.x
p=7    # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@fn)</code></td>
    <td><code>@fn</code></td>
    <td><code>eval(@fn)</code></td>
    <td><code>eval(eval(@fn))</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); :x; end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); :(x); end</code></td>
    <td><code>:(Main.x)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); quot(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); QuoteNode(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); :(:x); end</code></td>
    <td><code>:(:x)</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); quote; :x; end end</code></td>
    <td><code>quote
    :x
end</code></td>
    <td><code>:x</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
  </tr>
</table>

### Case - Global space basic expressions:

```julia
x=:p   # Main.x
p=7    # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@fn)</code></td>
    <td><code>@fn</code></td>
    <td><code>eval(@fn)</code></td>
    <td><code>eval(eval(@fn))</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); :($x); end</code></td>
    <td><code>:(Main.p)</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); :($(esc(x))); end</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
  <tr>
    <td><code>macro fn(); quot(x); end</code></td>
    <td><code>:(:p)</code></td>
    <td><code>:p</code></td>
    <td><code>7</code></td>
    <td><code>7</code></td>
  </tr>
</table>

### Case - Nested quote: https://docs.julialang.org/en/v1/manual/metaprogramming/#Nested-quote

```julia
n=1 + 2
```
<table>
  <tr>
    <td></td>
    <td><code>e</code></td>
    <td><code>eval(e)</code></td>
  </tr>
  <tr>
    <td><code>e=quote quote $n end end</code></td>
    <td><code>quote
    $(Expr(:quote, quote
    $(Expr(:$, :n))
end))
end</code></td>
    <td><code>quote
    1 + 2
end</code></td>
  </tr>
  <tr>
    <td><code>e=quote quote $$n end end</code></td>
    <td><code>quote
    $(Expr(:quote, quote
    $(Expr(:$, :(1 + 2)))
end))
end</code></td>
    <td><code>quote
    3
end</code></td>
  </tr>
  <tr>
    <td><code>e=quote quot($n) end</code></td>
    <td><code>quote
    quot(1 + 2)
end</code></td>
    <td><code>:($(Expr(:quote, 3)))</code></td>
  </tr>
  <tr>
    <td><code>e=quote QuoteNode($n) end</code></td>
    <td><code>quote
    QuoteNode(1 + 2)
end</code></td>
    <td><code>:($(QuoteNode(3)))</code></td>
  </tr>
</table>

### Case - Expression hygiene:

```julia
ex=:ey  # Main.ex
p=7     # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>let p=3;
 @dummy p^2;
end</code></td>
    <td><code>let p=3;
 @macroexpand @dummy p^2;
end</code></td>
    <td><code>let p=3;
 @dummy z=p^2;
end</code></td>
    <td><code>let p=3;
 @macroexpand @dummy z=p^2;
end</code></td>
  </tr>
  <tr>
    <td><code>macro dummy(ex); return ex; end</code></td>
    <td><code>49</code></td>
    <td><code>:(Main.p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>:(var"#1042#z" = Main.p ^ 2)</code></td>
  </tr>
  <tr>
    <td><code>macro dummy(ex); return esc(ex); end</code></td>
    <td><code>9</code></td>
    <td><code>:(p ^ 2)</code></td>
    <td><code>9</code></td>
    <td><code>:(z = p ^ 2)</code></td>
  </tr>
</table>

### Case - Medium expression:

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

### Case - Medium expression:

```julia
ex=:ey  # Main.ex
p=7     # Main.p
```
<table>
  <tr>
    <td></td>
    <td><code>@macroexpand(@fn z=p^2)</code></td>
    <td><code>@fn z=p^2</code></td>
    <td><code>let p=3; @fn z=p^2; end</code></td>
    <td><code>eval(@fn z=p^2)</code></td>
    <td><code>eval(eval(@fn z=p^2))</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); ex; end</code></td>
    <td><code>:(var"#1043#z" = Main.p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($ex); end</code></td>
    <td><code>:(var"#1051#z" = Main.p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quote; $ex; end end</code></td>
    <td><code>quote
    var"#1059#z" = Main.p ^ 2
end</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($(esc(ex))); end</code></td>
    <td><code>:(z = p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>9</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quote; $(esc(ex)); end end</code></td>
    <td><code>quote
    z = p ^ 2
end</code></td>
    <td><code>49</code></td>
    <td><code>9</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quot(ex); end</code></td>
    <td><code>:($(Expr(:copyast, :($(QuoteNode(:(z = p ^ 2)))))))</code></td>
    <td><code>:(z = p ^ 2)</code></td>
    <td><code>:(z = p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); QuoteNode(ex); end</code></td>
    <td><code>:($(QuoteNode(:(z = p ^ 2))))</code></td>
    <td><code>:(z = p ^ 2)</code></td>
    <td><code>:(z = p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :ex; end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>UndefVarError(:ez)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(ex); end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>UndefVarError(:ez)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($(:ex)); end</code></td>
    <td><code>:(Main.ex)</code></td>
    <td><code>:ey</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
    <td><code>UndefVarError(:ez)</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(:ex); end</code></td>
    <td><code>:(:ex)</code></td>
    <td><code>:ex</code></td>
    <td><code>:ex</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quot(:ex); end</code></td>
    <td><code>:(:ex)</code></td>
    <td><code>:ex</code></td>
    <td><code>:ex</code></td>
    <td><code>:ey</code></td>
    <td><code>:ez</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); QuoteNode(:ex); end</code></td>
    <td><code>:(:ex)</code></td>
    <td><code>:ex</code></td>
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
    <td><code>"ey"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :(string($ex)); end</code></td>
    <td><code>:(Main.string($(Expr(:(=), Symbol("#1077#z"), :(Main.p ^ 2)))))</code></td>
    <td><code>"49"</code></td>
    <td><code>"49"</code></td>
    <td><code>"49"</code></td>
    <td><code>"49"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); string(ex); end</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($(string(ex))); end</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
    <td><code>"z = p ^ 2"</code></td>
  </tr>
</table>
## Possible antipatterns:

- If you validate the `ex.head`, then using the function in a macro can lead to unusability due to escaping the expression to reach local scope. Because it is `$(Expr(:escape, VAR))` where `ex.head` == `:escape`. Issue: https://github.com/JuliaLang/julia/issues/37691 (So while this is an edge case we should be keep it in our mind if we want to create really universal macros.)
	
## Frequent mistakes:
 
- `$esc(…)` instead of `$(esc(…))`

- `$QuoteNode(…)` instead of `$(QuoteNode(…))`


## Sources:

- https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-

- https://nextjournal.com/a/KpqWNKDvNLnkBrgiasA35?change-id=CQRuZrWB1XaT71H92x8Y2Q


## Need simplification
Section: https://docs.julialang.org/en/v1/manual/metaprogramming/#man-quote-node

Still total chaotic for me and cannot make a simple explanation. My weak explanation throught tests: 
 
```julia
                       :(   $:(1+2))   #                               :(1 + 2)  note if it would be $n then of course the interpolation would be visible!
                    Expr(:$, :(1+2))   #                  :($(Expr(:$, :(1 + 2))))
               quot(Expr(:$, :(1+2))   # :($(Expr(:quote, :($(Expr(:$, :(1 + 2)))))))
          QuoteNode(Expr(:$, :(1+2))   #    :($(QuoteNode(:($(Expr(:$, :(1 + 2)))))))
               eval(Expr(:$, :(1+2))   # ERROR: syntax: "$" expression outside quote
          eval(quot(Expr(:$, :(1+2)))  # 3
     eval(QuoteNode(Expr(:$, :(1+2)))  #                  :($(Expr(:$, :(1 + 2))))
eval(eval(QuoteNode(Expr(:$, :(1+2)))) # 3
```
