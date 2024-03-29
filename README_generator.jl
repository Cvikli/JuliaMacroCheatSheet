include("README_generation_fn.jl")

isdir("./JuliaMacroCheatSheet") && cd("./JuliaMacroCheatSheet")
println(pwd())

open("README.md", "w") do file
write(file,"""# Julia Macro CheatSheet

The whole file is wider on this screen: https://github.com/Cvikli/JuliaMacroCheatSheet/blob/main/README.md

For me https://docs.julialang.org/en/v1/manual/metaprogramming/ just couldn't make these things understand so I tried to be as short as possible to reach understanding in each point. \n
Please help us correct things and any simplification is welcomed, It is still a little bit too complicated I know, this have to be even shorter! 

""")

write(file,"""## Macro hygiene (aka: SCOPE management)
In short: Escape: = "Access the local scope from where the macro is called!"
In macro hygiene, each interpolated variable(`VAR`) in the macro points to the module where the macro is defined (ex: `Main.VAR` or `MyModule.VAR`) instead of the local `VAR` in the macro's calling scope. 
```julia
a=1
macro ✖();    :(\$:a); end        
eval(let a=2; :(\$a);  end)        # =2  (exactly the same like: (`let a=2; a; end`))
     let a=2; @✖();   end          # =1
macro ✓();    :(\$(esc(:a))); end   
eval(let a=2; :(\$(esc(:a))); end) # ERROR: syntax: invalid syntax (escape (outerref a))
     let a=2; @✓();          end   # =2
```
BUT it generates new variable for the macro scope instead of the "local" scope. So eventually it doesn't see the outer scope variables in this case and believe this is the "new scope where the expression has to work".
```
a=1
macro ✖(ex); :(\$ex); end         
macro ✓(ex); :(\$(esc(ex))); end   # this works similarly: `:($(QuoteNode(ex)))`
eval(        :(a=2))               # a=2
# eval(        :(\$(esc(a=3))))    # ERROR: MethodError: no method matching esc(; b::Int64)
@✖ a=4                             # a=2
@✓ a=5                             # a=5
display(@macroexpand @✖ a=4)       # :(var"#54#a" = 4)
display(@macroexpand @✓ a=5)       # :(a = 5)
```
also
```
macro ✖(va, ex); :(\$va=\$ex); end 
macro ✓(va, ex); :(\$(esc(va))=\$(esc(ex))); end 
@✖ a 5
@✓ a 6
display(@macroexpand @✖ a 5)
display(@macroexpand @✓ a 6)
```
First we work in the macro scope, so it shadows(`gensym(:a)`) the variable. We need to use `esc` to reach the local scope. 

""")
write(file,"""## Reducing redundancy
```
quote 2+3 end == :(begin 2+3 end)  # both preserve the linenumbers (verifiable with `dump(…)`)
:(2+3)                             # also similar but without FIRST Linenumber
```
""")
write(file,"""## Evaluation time
`\$` (expression interpolation) evaluates when the expression is constructed (at parse time)\n
`:` or `quote` … `end`(Quotations) evaluates only when the expression is passed to eval at runtime.

""")
write(file,"""## Learning/repeating knowledge from tests

Note: 
- All test has included `using Base.Meta: quot, QuoteNode`.
- Linenumbers are removed from the CheatSheet!

""")

	basic_expression_generation_tests(file)
	global_basic_expression_generation_tests(file)
	nested_quote(file)
	macro_hygiene(file)
	medium_expression_generation_tests(file)
	advanced_expression_generation_tests(file)

	basic_tests(file)
	value_interpolation_tests(file)
	# expression_interpolation_tests(file)
	advanced_expression_interpolation_tests(file)


	write(file,"""\n\n## Possible antipatterns:\n
- If you validate the `ex.head`, then using the function in a macro can lead to unusability due to escaping the expression to reach local scope. Because it is `\$(Expr(:escape, VAR))` where `ex.head` == `:escape`. Issue: https://github.com/JuliaLang/julia/issues/37691 (So while this is an edge case we should be keep it in our mind if we want to create really universal macros.)
	
""")
write(file,"""## Frequent mistakes:\n 
- `\$esc(…)` instead of `\$(esc(…))`\n
- `\$QuoteNode(…)` instead of `\$(QuoteNode(…))`\n

""")
	write(file,"""## Sources:\n
- https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-\n
- https://nextjournal.com/a/KpqWNKDvNLnkBrgiasA35?change-id=CQRuZrWB1XaT71H92x8Y2Q\n

""")
	write(file,"""## Need simplification
Section: https://docs.julialang.org/en/v1/manual/metaprogramming/#man-quote-node\n
Still total chaotic for me and cannot make a simple explanation. My weak explanation throught tests: \n 
```julia
                       :(   \$:(1+2))   #                               :(1 + 2)  note if it would be \$n then of course the interpolation would be visible!
                    Expr(:\$, :(1+2))   #                  :(\$(Expr(:\$, :(1 + 2))))
               quot(Expr(:\$, :(1+2))   # :(\$(Expr(:quote, :(\$(Expr(:\$, :(1 + 2)))))))
          QuoteNode(Expr(:\$, :(1+2))   #    :(\$(QuoteNode(:(\$(Expr(:\$, :(1 + 2)))))))
               eval(Expr(:\$, :(1+2))   # ERROR: syntax: "\$" expression outside quote
          eval(quot(Expr(:\$, :(1+2)))  # 3
     eval(QuoteNode(Expr(:\$, :(1+2)))  #                  :(\$(Expr(:\$, :(1 + 2))))
eval(eval(QuoteNode(Expr(:\$, :(1+2)))) # 3
```
\n\n
Unfinished but main doc is okay actually:\n
- https://docs.julialang.org/en/v1/manual/metaprogramming/#meta-non-standard-string-literals\n
- https://docs.julialang.org/en/v1/manual/metaprogramming/#Generated-functions\n
""")
write(file,"""\n\n## This readme is generated by [README_generator.jl](https://github.com/Cvikli/JuliaMacroCheatSheet/blob/main/README_generator.jl)]\n
""")

end

ll = split(read(`git ls-files --modified`, String), '\n')
if length(ll)>1
	run(`git add .`)
	run(`git commit -m "autocommit"`)
	run(`git push`)
end
#%%
