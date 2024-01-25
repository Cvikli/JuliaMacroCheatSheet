
#%%
var="ok"
fn(var) || @fn var
#%%

macro fn(ex)
	quote
		println(...)
	end
end
#%%
function fn0_1(ex) 
	quote
		println(ex)
	end
end
function fn0_2(ex) 
	quote
		println($(ex))
	end
end
function fn0_3(ex) 
	quote
		println($(esc(ex)))
	end
end
function fn0_4(ex) 
	quote
		println(gensym())
	end
end
function fn0_5(ex) 
	quote
		ss=gensym()
		println(ss)
	end
end
var="ok"
# fn0_1(var)
fn0_2(var)
# fn0_3(var)
fn0_4(var)
fn0_5(var)
#%%

function fn1_1(ex) 
  println(ex)
end
# function fn1_2(ex) 
#   println($(ex))
# end
# function fn1_3(ex) 
#   println($(esc(ex)))
# end
function fn1_4(ex) 
  println(gensym())
end
function fn1_5(ex) 
	ss=gensym()
  println(ss)
end
# function fn1_6(ex) 
# 	println($(string(ss)))
# end

macro fn2_1(ex) 
  println(ex)
end
# macro fn2_2(ex) 
#   println($ex)
# end
# macro fn2_3(ex) 
#   println($(esc(ex)))
# end
macro fn2_4(ex) 
	ss=gensym()
  println(ss)
end
macro fn2_5(ex) 
	ss=gensym()
	println(ss)
end
# macro fn2_6(ex) 
# 	println($(string(ss)))
# end

macro fn3_1(ex) 
  :(println(ex))
end
macro fn3_2(ex) 
  :(println($(ex)))
end
macro fn3_3(ex) 
  :(println($(esc(ex))))
end
macro fn3_4(ex) 
  :(ss=gensym()),
  :(println(ss))
end
macro fn3_6(ex) 
  :(println($(string(ex))))
end
macro fn4_1(ex) 
	ok = 7
  quote
		@show $ok
		@show (ex, $ex, $(esc(ex)))
	end
end
macro fn4_2(ex) 
  quote
		println($ex)
	end
end
macro fn4_3(ex) 
  quote
		println($(esc(ex)))
	end
end
macro fn4_4(ex) 
  quote
		println(gensym())
	end
end

macro fn4_5(ex) 
  quote
		ss=gensym()
		println(ss)
	end
end
macro fn4_6(ex) 
  quote
		println($(string(ex)))
	end
end

# ex="???"
var="ok"
# @fn2_1(var)
# fn1_0(var)
# fn1_5(var)
# @macroexpand fn1_5(var)

# @fn4_5 var

@fn3_6 var
@fn4_6 var

#%%

macro fn4_6(ex) 
	# ss=gensym()
	ss="ok"
  quote
		println($(esc(ss)))
	end
end
@fn4_6 var
#%%
ex="outerescope"
var=9
macro qqq(ex) 
  quote
		println(ex," ",$ex," ",string(ex)," ",$(string(ex))," ", ($(esc(ex))))
	end
end
@qqq(ww=3)
#%%
ww
#%%
macro mysym(); :x; end
macro mysym2(); quot(:x); end


#%%
#%%



hyg="ok"

#%%


#%%

ex
$(ex)
$(esc(ex))
gensym()

ss=gensym()
println(ss)



#%%
macro quo(arg)
	:( x = $(esc(arg)); :($x + $x) )
end

#%%
macro quo(arg)
	:( x = $(quot(arg)); :($x + $x) )
end

#%%
macro quo(arg)
	:( x = $(QuoteNode(arg)); :($x + $x) )
end
#%%
@quo 1
#%%
eval(@quo 1)
#%%
@quo 1 + 1
#%%
eval(@quo 1 + 1)
#%%
@quo 1 + $(sin(1))
#%%
let q = 0.5 
  @quo 1 + $q
end
#%%
let q = 0.5 
	eval(@quo 1 + $q)
end




#%%

using Base.Meta: quot, QuoteNode

#%%
p=8
x=:p
println("<table>")
println("  <tr>
    <td></td>
    <td><code>@macroexpand(@sym)</code></td>
    <td><code>@sym</code></td>
    <td><code>eval(@sym)</code></td>
  </tr>")
println("  <tr>")
macro sym(); :x; end
println("    <td><code>","macro sym(); :x; end","</code></td>")
print("    <td><code>"); print(@macroexpand(@sym)); println("</code></td>")
print("    <td><code>"); print(@sym); println("</code></td>")
print("    <td><code>"); print(eval(@sym)); println("</code></td>")
println("  </tr>
  <tr>")
macro sym(); :(x); end
println("    <td><code>","macro sym(); :(x); end","</code></td>")
print("    <td><code>"); print(@macroexpand(@sym)); println("</code></td>"); 
print("    <td><code>"); print(@sym); println("</code></td>"); 
print("    <td><code>"); print(eval(@sym)); println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(); :(:x); end
println("    <td><code>","macro sym(); :(:x); end","</code></td>")
print("    <td><code>"); print(@macroexpand(@sym)); println("</code></td>"); 
print("    <td><code>"); print(@sym); println("</code></td>"); 
print("    <td><code>"); print(eval(@sym)); println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(); quot(x); end
println("    <td><code>","macro sym(); quot(x); end","</code></td>")
print("    <td><code>"); print(@macroexpand(@sym)); println("</code></td>"); 
print("    <td><code>"); print(@sym); println("</code></td>"); 
print("    <td><code>"); print(eval(@sym)); println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(); quot(:x); end
println("  <td><code>","macro sym(); quot(:x); end","</code></td>")
print("    <td><code>"); print(@macroexpand(@sym)); println("</code></td>"); 
print("    <td><code>"); print(@sym); println("</code></td>"); 
print("    <td><code>"); print(eval(@sym)); println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(); QuoteNode(:x); end
println("    <td><code>","macro sym(); QuoteNode(:x); end","</code></td>")
print("    <td><code>"); print(@macroexpand((@sym))); println("</code></td>"); 
print("    <td><code>"); print(@sym); println("</code></td>"); 
print("    <td><code>"); print(eval(@sym)); println("</code></td>"); 
println("  </tr>")
println("</table>")
println()
#%%
println("""```julia
using Base.Meta: quot, QuoteNode
ex=:ey
y=:p
p=8
```""")
ex=:ey
y=:p
p=8
println("<table>")
println("  <tr>
    <td></td>
    <td><code>@macroexpand(@sym y)</code></td>
    <td><code>@macroexpand(@sym \$y)</code></td>
    <td><code>@sym y</code></td>
  </tr>")
println("  <tr>")
macro sym(ex); :($ex); end
print("    <td><code>"); print("macro sym(ex); :(\$ex); end"); println("</code></td>"); 
print("    <td><code>"); print(@macroexpand(@sym y)); println("</code></td>"); 
print("    <td><code>"); print(@macroexpand(@sym $y)); println("</code></td>"); 
print("    <td><code>"); print(@sym y); println("</code></td>"); 
# print("    <td><code>"); print(@sym $y); println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(ex); :(:($ex)); end
print("    <td><code>"); print("macro sym(ex); :(:(\$ex)); end");  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym y)));  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym $y)));  println("</code></td>"); 
print("    <td><code>"); print(@sym y);  println("</code></td>"); 
# print("    <td><code>"); print(@sym $y);  println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(ex); :($:($ex)); end
print("    <td><code>"); print("macro sym(ex); :(\$:(\$ex)); end");  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym y)));  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym $y)));  println("</code></td>"); 
print("    <td><code>"); print(@sym y);  println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(ex); :(quot($ex)); end
print("    <td><code>"); print("macro sym(ex) 
  :(quot(\$ex))
end");  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym y)));  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym $y)));  println("</code></td>"); 
print("    <td><code>"); print(@sym y);  println("</code></td>"); 
# print("    <td><code>"); print(@sym $y);  println("</code></td>"); 
println("  </tr>
  <tr>")
macro sym(ex); :(QuoteNode($ex)); end
print("    <td><code>"); print("macro sym(ex)
  :(QuoteNode(\$ex))
end");  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym y)));  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym $y)));  println("</code></td>"); 
print("    <td><code>"); print(@sym y);  println("</code></td>"); 
# print("    <td><code>"); print(@sym $y);  println("</code></td>"); 
println("  </tr>")
println("</table>")
#%%
macro literal(s)
	s
end
println("<table>")
fn() = begin
	ex=:ey
y=:p
p=8
tests = [
"macro sym(ex)
 ex
end",
"macro sym(ex)
 :(ex)
end",
"macro sym(ex)
 :(\$ex)
end",
"macro sym(ex)
 :(\$:(\$ex))
end",
"macro sym(ex)
 :(quot(\$ex))
end",
"macro sym(ex)
 QuoteNode(ex)
end",
"macro sym(ex)
 :(QuoteNode(\$ex))
end",
"macro sym(ex)
 :(\$(QuoteNode(ex)))
end",
"macro sym(ex); quote 
 QuoteNode(\$ex)
end; end",
"macro sym(ex); quote
 \$(QuoteNode(ex))
end; end",
		]
	cases = [
		"@macroexpand(@sym y)",
		"@macroexpand(@sym \$y)",
		"@sym y",
		"eval(@sym y)",
		"@sym \$y",
	]
		
	println("  <tr>")
	println("    <td></td>")
	for case in cases
		println("    <td><code>",case,"</code></td>")
	end
	println("  </tr>")


	for mac in tests
		println("  <tr>")
		eval(Meta.parse(mac))
		print("    <td><code>"); print(mac);  println("</code></td>"); 
		for case in cases
			print("    <td><code>"); 
			try	print(replace("$(eval(Meta.parse(case)))",
				"    #= none:1 =#\n"=>"", 
				"    #= none:2 =#\n"=>"", 
				"    "=>"  ")); 
			catch e
				if isa(e,UndefVarError)
					print(e)
				elseif isa(e,ErrorException)
					print(e.msg)
				else
					println()
					print(e)
					print(typeof(e))
					print(fieldnames(typeof(e)))
					@assert false ""
				end
			end
			println("</code></td>"); 
		end
		println("  </tr>")
	end
end
fn()
println("</table>")
#%%
"This macro \t escapes \n any special (characters) for you."
#%%
try
	eval(Meta.parse("@sym \$y"))
catch e

end
#%%
println("  </tr>
  <tr>")

print("    <td><code>"); print("macro sym(ex)
  :(QuoteNode(\$ex))
end");  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym y)));  println("</code></td>"); 
print("    <td><code>"); print(@macroexpand((@sym $y)));  println("</code></td>"); 
print("    <td><code>"); print(@sym y);  println("</code></td>"); 
print("    <td><code>"); print(@sym $y);  println("</code></td>"); 

#%%
macro quo(arg)
	:( x = $(esc(arg)); :($x + $x) )
end

#%%
macro quo(arg)
	:( x = $(quot(arg)); :($x + $x) )
end

#%%
macro quo(arg)
	:( x = $(QuoteNode(arg)); :($x + $x) )
end
#%%
@quo 1
#%%
eval(@quo 1)
#%%
@quo 1 + 1
#%%
eval(@quo 1 + 1)
#%%
@quo 1 + $(sin(1))
#%%
let q = 0.5 
  @quo 1 + $q
end
#%%
let q = 0.5 
	eval(@quo 1 + $q)
end


#%%
macro ip(ex, l, r)
	quote
		($ex)
		((($l)) + (($r)))
	end
end
macro ip(l, r)
	# :($(quot(l)) + $(quot(r)))
	:((quot($l)) + (quot($r)))
end
macro ip3(ex, l, r)
	quote
		quot($ex)
		:($$(quot(l)) + $$(quot(r)))
	end
end
y=1
display(@macroexpand @ip $y $y)
display(@ip $y $y)
display(eval(@ip $y $y))
display(@ip x=3 x x)
display(@ip3 x=1 $x $x)
display(eval(@ip3 x=1 $x $x))


#%%
macro ip(ex, l, r)
	quote
		quot($ex)
		:($$(quot(l)) + $$(quot(r)))
	end
end
#%%
macro ip(ex, l, r)
	quote
		$(quot(ex))
		:($$(quot(l)) + $$(quot(r)))
	end
end
#%%
macro ip(ex, l, r)
	quote
		quote
			$$(quot(ex))
			:($$$(quot(l)) + $$$(quot(r)))
		end
	end
end
#%%
macro ip(ex, l, r)
	quote
		quote
			$$(quot(ex))
			:($$(quot($(quot(l)))) + $$(quot($(quot(r)))))
		end
	end
end
#%%
macro ip(ex, l, r)
	quote
		quote
			$$(quot(ex))
			:($$(quot($(QuoteNode(l)))) + $$(quot($(QuoteNode(r)))))
		end
	end
end
#%%
macro qq(out) 
	print("<td style=\"background-color: #e55; color: #222\">",eval(:($(QuoteNode(out)))),"</td>")
end
col=1
@show "EFEEFEFE"
# display(@ip x=1 x x)
# display(eval(@ip x=1 x x))
# display(eval(eval(@ip x=1 x x)))
# display(@ip x=1 x/2 x)
# display(eval(@ip x=1 x/2 x))
# display(@ip x=1 1/2 1/4)
# display(eval(@ip x=1 1/2 1/4))
display(@ip x=1 $x $x)
display(eval(@ip x=1 $x $x))
display(@ip x=1 1+$x $x)
display(eval(@ip x=1 1+$x $x))
display(@ip x=1 $x/2 $x)
display(eval(@ip x=1 $x/2 $x))
#%%
#%%
#%%
#%%
#%%
#%%
#%%
#%%
#%%
:(5 + 3)
#%%

