
using Base.Meta: quot, QuoteNode
using MacroTools

gen_all_cases(io,title, init, tests, cases) = begin
	println(io,'\n',title,'\n')
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
			try	show(TextDisplay(io).io, MIME"text/plain"(),
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
value_interpolation_tests(io) = begin
	title = "Case - Value interpolation:"
	init  = "q=:p  # Main.q\n"*
	        "p=7   # Main.p"
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
	"@quo 2",
	"@quo 2 + 2",
	"@quo 2 + \$(sin(1))",
	"@quo 2 + \$q",
	"eval(@quo 2 + \$q)",
]
	gen_all_cases(io,title,init,tests,cases)
end
# value_interpolation_tests(stdout)
#%%

expression_generation_tests(io) = begin
	title = "Case - Expression generation:"
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
	gen_all_cases(io,title,init,tests,cases)
end
# expression_generation_tests(stdout)
#%%
expression_interpolation_tests(io) = begin
	title = "Case - Expression interpolation:"
	init= "ex=:ey   #  Main.ex\n"*
				"y=:p     #  Main.y\n"*
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
	gen_all_cases(io,title,init,tests,cases)
end
# expression_interpolation_tests(stdout)
#%%
advanced_expression_interpolation_tests(io) = begin
	title = "Case - Advanced expression interpolation  (note: @ip: interpolation, l: left, r: r):"
	init= "ex=:ey   #  Main.ex\n"*
				"y=:p     #  Main.y\n"*
				"p=8      #  Main.p"
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
		"@ip x=1 x x",
		"eval(@ip x=1 x x)",
		"eval(eval(@ip x=1 x x))",
		"@ip x=1 x/2 x",
		"eval(@ip x=1 x/2 x)",
		"@ip x=1 1/2 1/4",
		"eval(@ip x=1 1/2 1/4)",
		"@ip x=1 \$x \$x",
		"eval(@ip x=1 1+\$x \$x)",
		"@ip x=1 \$x/2 \$x",
		"eval(@ip x=1 \$x/2 \$x)",
	]
	gen_all_cases(io,title,init,tests,cases)
end
advanced_expression_interpolation_tests(stdout)