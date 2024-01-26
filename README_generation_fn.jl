
using Base.Meta: quot, QuoteNode
using MacroTools

ex=Symbol("ey")  # Main.ex
ey=Symbol("ez")  # Main.ex
x=Symbol("p")    # Main.x
y=Symbol("p")    # Main.y
q=Symbol("p")    # Main.q
p=7              # Main.p
n=:(1+2)         # Main.n
a=1


gen_all_cases(io,title, init, tests, cases) = begin
	println(io,'\n',"### ",title,'\n')
	!isempty(init) && println(io,"""```julia
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
			try	
				show(TextDisplay(io).io, MIME"text/plain"(),
				# replace("$(
					MacroTools.striplines(eval(MacroTools.striplines(Meta.parse(case))))
				# )",
				# "    #= none:1 =#\n"=>"", 
				# "    #= none:2 =#\n"=>"", 
				# "    "=>"  ")
				); 
			catch e
				if isa(e,UndefVarError)
					print(io,e)
				elseif isa(e,ErrorException)
					print(io,e.msg)
				elseif isa(e,MethodError)
					print(io,"MethodError: $(e.f)$(e.args)")
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
gen_all_cases_internal(io,title, init, tests, cases, call) = begin
	println(io,'\n',"### ",title,'\n')
	!isempty(init) && println(io,"""```julia
	$init
	```""")
	println(io,"<table>")
	println(io,"  <tr>")
	println(io,"    <td>$(call)</td>")
	for case in cases
		println(io,"    <td><code>",case,"</code></td>")
	end
	println(io,"  </tr>")

	eval(init)
	for (outer_space_first,outer_space_last) in tests
		println(io,"  <tr>")
		print(io,"    <td><code>"); print(io,outer_space_first,"…",outer_space_last);  println(io,"</code></td>"); 
		for inner_space in cases
			print(io,"    <td><code>"); 
			try	
				mac = join((outer_space_first,inner_space,outer_space_last), "")
				eval(Meta.parse(mac))

				aa=MacroTools.striplines(eval(MacroTools.striplines(Meta.parse(call))))
				# print("7")
				show(TextDisplay(io).io, MIME"text/plain"(),aa) 
			catch e
				if isa(e,UndefVarError)
					print(io,e)
				elseif isa(e,ErrorException)
					print(io,e.msg)
				elseif isa(e,MethodError)
					print(io,"MethodError: $(e.f)$(e.args)")
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
basic_tests(io) = begin
	title = "Case - Basic:"
	init  = "ex=:$(ex)   # Main.ex\n"*
					"x=:$(x)     # Main.x\n"*
					"p=$(p)      # Main.p"
	tests = [("macro fn(ex)
 ","
end"),
("macro fn(ex)
 quot(",")
end"),
("macro fn(ex)
 QuoteNode(",")
end"),
("macro fn(ex)
 :(",")
end"),
("macro fn(ex)
 quote
  ","
 end
end"),
]
	cases = [
		"ex",
		":ex",
		"string(ex)",
		":ey",
		":(ey)",
		"\$(ex)",
		"\$(esc(ex))",
		"\$(string(ex))",
		"string(\$ex)",
	]
	call = "@fn x"
	gen_all_cases_internal(io,title,init,tests,cases, call)
end
# basic_tests(stdout)
#%%
value_interpolation_tests(io) = begin
	title = "Case - Value interpolation:"
	init  = "q=:$(q)  # Main.q\n"*
	        "p=$(p)   # Main.p"
	tests = ["macro quo(ex)
 :(x=\$(esc(ex));
   :(\$x+\$x))
end",
"macro quo(ex)
 :(x=\$(quot(ex));
   :(\$x+\$x))
end",
"macro quo(ex)
 :(x=\$(QuoteNode(ex));
   :(\$x+\$x))
end"]
cases = [
"@quo 2",
"@quo 2 + 2",
"@quo 2 + \$(sin(1))",
"@quo 2 + \$q",
"eval(@quo 2 + \$q)",
]
	gen_all_cases(io,title,init,tests,cases)
end
# value_interpolation_tests(stdout)
#%%

basic_expression_generation_tests(io) = begin
	title = "Case - Basic expressions:"
	init  = "x=:$(x)   # Main.x\n"*
					"p=$(p)    # Main.p"
	tests = [
		"macro fn(); :x; end",
		"macro fn(); :(x); end",
		"macro fn(); quot(:x); end",
		"macro fn(); QuoteNode(:x); end",
		"macro fn(); :(:x); end",
		"macro fn(); quote; :x; end end",
		]
	cases = [
		"@macroexpand(@fn)",
		"@fn",
		"eval(@fn)",
		"eval(eval(@fn))",
	]
	gen_all_cases(io,title,init,tests,cases)
end
global_basic_expression_generation_tests(io) = begin
	title = "Case - Global space basic expressions:"
	init  = "x=:$(x)   # Main.x\n"*
					"p=$(p)    # Main.p"
	tests = [
		"macro fn(); :(\$x); end",
		"macro fn(); :(\$(esc(x))); end",
		"macro fn(); quot(x); end",
		]
	cases = [
		"@macroexpand(@fn)",
		"@fn",
		"eval(@fn)",
		"eval(eval(@fn))",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# global_basic_expression_generation_tests(stdout)
#%%

medium_expression_generation_tests(io) = begin
	title = "Case - Medium expression:"
	init  = "ex=:$(ex)  # Main.ex\n"*
					"x=:$(x)    # Main.x\n"*
					"p=$(p)     # Main.p"
	tests = [
		"macro fn(ex); ex; end",
		"macro fn(ex); :(\$ex); end",
		"macro fn(ex); quote; \$ex; end end",
		"macro fn(ex); :(\$(esc(ex))); end",
		"macro fn(ex); quote; \$(esc(ex)); end end",
		"macro fn(ex); quot(ex); end",
		"macro fn(ex); QuoteNode(ex); end",
		"macro fn(ex); :ex; end",
		"macro fn(ex); :(ex); end",
		"macro fn(ex); :(\$(:ex)); end",
		"macro fn(ex); :(:ex); end",
		"macro fn(ex); quot(:ex); end",
		"macro fn(ex); QuoteNode(:ex); end",
		"macro fn(ex); quote; :ex; end end",
		"macro fn(ex); :(string(ex)); end",
		"macro fn(ex); :(string(\$ex)); end",
		"macro fn(ex); string(ex); end",
		"macro fn(ex); :(\$(string(ex))); end",
		# "macro fn(ex); :(string(esc(\$ex))); end",
		]
	cases = [
		"@macroexpand(@fn x)",
		"@fn x",
		"eval(@fn x)",
		"eval(eval(@fn x))",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# medium_expression_generation_tests(stdout)

#%%

advanced_expression_generation_tests(io) = begin
	title = "Case - Medium expression:"
	init  = "ex=:$(ex)  # Main.ex\n"*
					"p=$(p)     # Main.p"
	tests = [
		"macro fn(ex); ex; end",
		"macro fn(ex); :(\$ex); end",
		"macro fn(ex); quote; \$ex; end end",
		"macro fn(ex); :(\$(esc(ex))); end",
		"macro fn(ex); quote; \$(esc(ex)); end end",
		"macro fn(ex); quot(ex); end",
		"macro fn(ex); QuoteNode(ex); end",
		"macro fn(ex); :ex; end",
		"macro fn(ex); :(ex); end",
		"macro fn(ex); :(\$(:ex)); end",
		"macro fn(ex); :(:ex); end",
		"macro fn(ex); quot(:ex); end",
		"macro fn(ex); QuoteNode(:ex); end",
		"macro fn(ex); quote; :ex; end end",
		"macro fn(ex); :(string(ex)); end",
		"macro fn(ex); :(string(\$ex)); end",
		"macro fn(ex); string(ex); end",
		"macro fn(ex); :(\$(string(ex))); end",
		# "macro fn(ex); :(string(esc(\$ex))); end",
		]
	cases = [
		"@macroexpand(@fn z=p^2)",
		"@fn z=p^2",
		"let p=3; @fn z=p^2; end",
		"eval(@fn z=p^2)",
		"eval(eval(@fn z=p^2))",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# advanced_expression_generation_tests(stdout)
#%%

macro_hygiene(io) = begin
	title = "Case - Expression hygiene:"
	init  = "ex=:$(ex)  # Main.ex\n"*
					"p=$(p)     # Main.p"
	tests = [
		"macro dummy(ex); return ex; end",
		"macro dummy(ex); return esc(ex); end",
		]
	cases = [
		# "@dummy z=p^2",
		# "@macroexpand @dummy z=p^2",
    "let p=3;
 @dummy p^2;
end",
		"let p=3;
 @macroexpand @dummy p^2;
end",
    "let p=3;
 @dummy z=p^2;
end",
		"let p=3;
 @macroexpand @dummy z=p^2;
end",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# macro_hygiene(stdout)
#%%

nested_quote(io) = begin
	title = "Case - Nested quote: https://docs.julialang.org/en/v1/manual/metaprogramming/#Nested-quote"
	init  = "n=:($n)"
	tests = [
		"e=quote quote \$n end end",
		"e=quote quote \$\$n end end",
		"e=quote quot(\$n) end",
		"e=quote QuoteNode(\$n) end",
		]
	cases = [
		"e",
		"eval(e)",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# nested_quote(stdout)
#%%
expression_interpolation_tests(io) = begin
	title = "Case - Expression interpolation:"
	init= "ex=:$(ex)   #  Main.ex\n"*
				"x=:$(x)     #  Main.x\n"*
				"p=$(p)      #  Main.p"
	tests = [
"macro fn(ex)
 ex
end",
"macro fn(ex)
 :(ex)
end",
"macro fn(ex)
 :(\$ex)
end",
"macro fn(ex)
 :(\$:(\$ex))
end",
"macro fn(ex)
 :(quot(\$ex))
end",
"macro fn(ex)
 QuoteNode(ex)
end",
"macro fn(ex)
 :(QuoteNode(\$ex))
end",
"macro fn(ex)
 :(\$(QuoteNode(ex)))
end",
"macro fn(ex); quote 
 QuoteNode(\$ex)
end; end",
"macro fn(ex); quote
 \$(QuoteNode(ex))
end; end",
		]
	cases = [
"@macroexpand(@fn x)",
"@macroexpand(@fn \$x)",
"@fn x",
"eval(@fn x)",
"@fn \$x",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# expression_interpolation_tests(stdout)
#%%
advanced_expression_interpolation_tests(io) = begin
	title = "Case - Advanced expression interpolation  (note: @ip: interpolation, l: left, r: r):"
	init= ""
	tests = [
"macro ip(ex, l, r)
quote
 Meta.quot(\$ex)
 :(\$\$(Meta.quot(l)) + \$\$(Meta.quot(r)))
end
end",
"macro ip(ex, l, r)
quote
 \$(Meta.quot(ex))
 :(\$\$(Meta.quot(l)) + \$\$(Meta.quot(r)))
 end
end",
"macro ip(ex, l, r)
quote
 quote
  \$\$(Meta.quot(ex))
  :(\$\$\$(Meta.quot(l)) + \$\$\$(Meta.quot(r)))
 end
end
end",
"macro ip(ex, l, r)
quote
 quote
  \$\$(Meta.quot(ex))
  :(\$\$\$(Meta.quot(l)) + \$\$\$(Meta.quot(r)))
 end
end
end",
"macro ip(ex, l, r)
quote
 quote
  \$\$(Meta.quot(ex))
  :(\$\$(Meta.quot(\$(Meta.quot(l)))) + \$\$(Meta.quot(\$(Meta.quot(r)))))
 end
end
end",
"macro ip(ex, l, r)
quote
 quote
  \$\$(Meta.quot(ex))
  :(\$\$(Meta.quot(\$(QuoteNode(l)))) + \$\$(Meta.quot(\$(QuoteNode(r)))))
 end
end
end",
		]
	cases = [
"@ip y=1 y y",
"eval(@ip y=1 y y)",
"eval(eval(@ip y=1 y y))",
"@ip y=1 y/2 y",
"eval(@ip y=1 y/2 y)",
"@ip y=1 1/2 1/4",
"eval(@ip y=1 1/2 1/4)",
"@ip y=1 \$y \$y",
"eval(@ip y=1 1+\$y \$y)",
"@ip y=1 \$y/2 \$y",
"eval(@ip y=1 \$y/2 \$y)",
	]
	gen_all_cases(io,title,init,tests,cases)
end
# advanced_expression_interpolation_tests(stdout)
