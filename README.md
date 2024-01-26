# Julia macro CheatSheet

The whole file is wider on this screen: https://github.com/Cvikli/JuliaMacroCheatSheet/blob/main/README.md

Frequent mistakes: 
- `$esc(…)` instead of `$(esc(…))`
- `$QuoteNode(…)` instead of `$(QuoteNode(…))`
## Reducing redundancy
```
quote 2+3 end == :(begin 2+3 end)  # even "Linenumbers are correct" (check with `dump(…)`)
:(2+3)                             # also similar but without FIRST Linenumber
```
## Macro hygenie (aka: SCOPE management)
Macro hygenie, each interpolated variable(`VAR`) in the macro scope points to `Main.VAR` instead of "local VAR in the macro calling scope". 
```julia
a=1
macro ✖();    :($:a); end        
eval(let a=2; :($a);  end)        # =2  (exactly the same like: (`let a=2; a; end`))
     let a=2; @✖();   end          # =1
macro ✓();    :($(esc(:a))); end   
eval(let a=2; :($(esc(:a))); end) # ERROR: syntax: invalid syntax (escape (outerref a))
     let a=2; @✓();          end   # =2
```
BUT it generate new variable for the macro scope instead of the "local" scope. So eventually it doesn't see the outer scope variables in this case and believe this is the "new scope where the expression has to work".
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
First we work in the macro scope, so it shadows the value. We need to use `esc` to reach the local scope. 

## Evaluation time
`$` (expression interpolation) evaluates when the expression is constructed (at parse time)

Quotation (with `:` or `quote` … `end`) evaluates only when the expression is passed to eval at runtime.

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

### Case - Expression hygenie:

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
    <td><code>:(var"#133#z" = Main.p ^ 2)</code></td>
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
    <td><code>:(var"#134#z" = Main.p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); :($ex); end</code></td>
    <td><code>:(var"#142#z" = Main.p ^ 2)</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
    <td><code>49</code></td>
  </tr>
  <tr>
    <td><code>macro fn(ex); quote; $ex; end end</code></td>
    <td><code>quote
    var"#150#z" = Main.p ^ 2
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
    <td><code>:(Main.string($(Expr(:(=), Symbol("#168#z"), :(Main.p ^ 2)))))</code></td>
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
Sources: 

- https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-

- https://nextjournal.com/a/KpqWNKDvNLnkBrgiasA35?change-id=CQRuZrWB1XaT71H92x8Y2Q

