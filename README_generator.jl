include("README_generation_fn.jl")

isdir("./JuliaMacroCheatSheet") && cd("./JuliaMacroCheatSheet")
println(pwd())

open("README.md", "w") do file
write(file,"""# Julia macro CheatSheet


Big mistakes: `\$QuoteNode(…)` instead of `\$(QuoteNode(…))`, `\$esc(…)` instead of `\$(esc(…))`
""")
o = '#'
write(file,"""## Reducing redundancy
```
quote 2+3 end == :(begin 2+3 end)  # even "Linenumbers are correct" (check with `dump(…)`)
:(2+3)                             # also similar but without FIRST Linenumber
```
""")

write(file,"""## Macro hygenie (aka: SCOPE management)
Macro hygenie, each interpolated variable(`VAR`) in the macro scope points to `Main.VAR` instead of "local VAR in the macro calling scope". 
```julia
a=1
macro w();    :(\$:a); end        
eval(let a=2; :(\$a);  end)        # =2  (exactly the same like: (`let a=2; a; end`))
     let a=2; @w();   end          # =1
macro g();    :(\$(esc(:a))); end   
eval(let a=2; :(\$(esc(:a))); end) # ERROR: syntax: invalid syntax (escape (outerref a))
     let a=2; @g();          end   # =2
```
BUT it generate new variable for the macro scope instead of the "local" scope. So eventually it doesn't see the outer scope variables in this case and believe this is the "new scope where the expression has to work".
```
a=1
macro s(ex); :(\$ex); end         
macro t(ex); :(\$(esc(ex))); end   
eval(        :(a=2)        )     # a=2
eval(        :(\$(esc(a=3))))    # ERROR: MethodError: no method matching esc(; b::Int64)
@s a=4                           # a=2
@t a=5                           # a=5
display(@macroexpand @s a=4)     # :(var"#54#a" = 4)
display(@macroexpand @t a=5)     # :(a = 5)
```

""")
write(file,"""## Evaluation time
`\$` (expression interpolation) evaluates when the expression is constructed (at parse time)
Quotation (with `:` or `quote` … `end`) evaluates only when the expression is passed to eval at runtime.

""")
write(file,"""## Learning/repeating knowledge from tests

Note: 
- All test has included `using Base.Meta: quot, QuoteNode`.
- Linenumbers are removed from the CheatSheet!

""")

	basic_expression_generation_tests(file)
	global_basic_expression_generation_tests(file)
	macro_hygenie(file)
	medium_expression_generation_tests(file)
	advanced_expression_generation_tests(file)

	# basic_tests(file)
	# value_interpolation_tests(file)
	# expression_interpolation_tests(file)
	# advanced_expression_interpolation_tests(file)


	write(file,"""Sources: https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-""")
	write(file,"""Sources: https://nextjournal.com/a/KpqWNKDvNLnkBrgiasA35?change-id=CQRuZrWB1XaT71H92x8Y2Q""")

end

ll = split(read(`git ls-files --modified`, String), '\n')
if length(ll)>1
	run(`git add .`)
	run(`git commit -m "autocommit"`)
	run(`git push`)
end
#%%
