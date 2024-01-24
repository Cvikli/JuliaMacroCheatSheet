
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
macro mysym2(); Meta.quot(:x); end


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
	:( x = $(Meta.quot(arg)); :($x + $x) )
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
macro ip(expr, left, right)
	quote
		Meta.quot($expr)
		:($$(Meta.quot(left)) + $$(Meta.quot(right)))
	end
end
#%%
macro ip(expr, left, right)
	quote
		$(Meta.quot(expr))
		:($$(Meta.quot(left)) + $$(Meta.quot(right)))
	end
end
#%%
macro ip(expr, left, right)
	quote
		quote
			$$(Meta.quot(expr))
			:($$$(Meta.quot(left)) + $$$(Meta.quot(right)))
		end
	end
end
#%%
macro ip(expr, left, right)
	quote
		quote
			$$(Meta.quot(expr))
			:($$(Meta.quot($(Meta.quot(left)))) + $$(Meta.quot($(Meta.quot(right)))))
		end
	end
end
#%%
macro ip(expr, left, right)
	quote
		quote
			$$(Meta.quot(expr))
			:($$(Meta.quot($(QuoteNode(left)))) + $$(Meta.quot($(QuoteNode(right)))))
		end
	end
end
#%%
macro qq(out) 
	print("<td style=\"background-color: #e55; color: #222\">",eval(:($(QuoteNode(out)))),"</td>")
end
col=1
@show "EFEEFEFE"
# display(@interpolate x=1 x x)
# display(eval(@interpolate x=1 x x))
# display(eval(eval(@interpolate x=1 x x)))
# display(@interpolate x=1 x/2 x)
# display(eval(@interpolate x=1 x/2 x))
# display(@interpolate x=1 1/2 1/4)
# display(eval(@interpolate x=1 1/2 1/4))
display(@interpolate x=1 $x $x)
display(eval(@interpolate x=1 $x $x))
display(@interpolate x=1 1+$x $x)
display(eval(@interpolate x=1 1+$x $x))
display(@interpolate x=1 $x/2 $x)
display(eval(@interpolate x=1 $x/2 $x))
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

