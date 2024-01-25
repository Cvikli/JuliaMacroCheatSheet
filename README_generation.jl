
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
#%%
using Base.Meta: quot, QuoteNode
gen_all_cases(io,init, tests, cases) = begin
	println(io,"""```julia
	$init
	```""")
	println(io,"<table>")
	println(io,"  <tr>")
	println(io,"    <td></td>")
	for case in cases
		println(io,"    <td><code>",case,"</code></td>")
	end
	println(io,"  </tr>")

	eval(init)
	for mac in tests
		println(io,"  <tr>")
		print(io,"    <td><code>"); print(io,mac);  println(io,"</code></td>"); 
		eval(Meta.parse(mac))
		for case in cases
			print(io,"    <td><code>"); 
			try	print(io,replace("$(eval(Meta.parse(case)))",
				"    #= none:1 =#\n"=>"", 
				"    #= none:2 =#\n"=>"", 
				"    "=>"  ")); 
			catch e
				if isa(e,UndefVarError)
					print(io,e)
				elseif isa(e,ErrorException)
					print(io,e.msg)
				else
					println(io)
					print(io,e)
					print(io,typeof(e))
					print(io,fieldnames(typeof(e)))
					@assert false ""
				end
			end
			println(io,"</code></td>"); 
		end
		println(io,"  </tr>")
	end
	println(io,"</table>")
end
#%%

value_interpolation_tests(io) = begin
	init  = ""
	tests = ["macro quo(ex)
 :( x = \$(esc(ex)); :(\$x + \$x) )
end",
"macro quo(ex)
 :( x = \$(quot(ex)); :(\$x + \$x) )
end",
"macro quo(ex)
 :( x = \$(QuoteNode(ex)); :(\$x + \$x) )
end"]
cases = [
	"@quo 1",
	"eval(@quo 1)",
	"@quo 1 + 1",
	"eval(@quo 1 + 1)",
	"@quo 1 + \$(sin(1))",
	"let q = 0.5 
  @quo 1 + \$q
end",
	"let q = 0.5 
  eval(@quo 1 + \$q)
end"
]
	gen_all_cases(io,init,tests,cases)
end
value_interpolation_tests(stdout)
#%%

expression_generation_tests(io) = begin
	init  = "x=:p  # Main.x\n"*
					"p=8   # Main.p"
	tests = [
		"macro sym(); :x; end",
		"macro sym(); :(x); end",
		"macro sym(); :(:x); end",
		"macro sym(); quot(x); end",
		"macro sym(); quot(:x); end",
		"macro sym(); QuoteNode(:x); end",
		]
	cases = [
		"@macroexpand(@sym)",
		"@sym",
		"eval(@sym)",
	]
	gen_all_cases(io,init,tests,cases)
end
expression_generation_tests(stdout)
#%%
expression_interpolation_tests(io) = begin
	init= "ex=:ey   #  Main.ex"*
				"y=:p     #  Main.y"*
				"p=8      #  Main.p"
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
	gen_all_cases(io,init,tests,cases)
end
expression_interpolation_tests(stdout)
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

