include("README_generation_fn.jl")

isdir("./JuliaMacroCheatSheet") && cd("./JuliaMacroCheatSheet")
println(pwd())

open("README.md", "w") do file
write(file,"""
# JuliaMacroCheatSheet
Macro CheatSheet


Note: Linenumbers are removed from the CheatSheet!
All test has included: `using Base.Meta: quot, QuoteNode`

Big mistakes: `\$QuoteNode(…)` instead of `\$(QuoteNode(…))` 

""")

	basic_expression_generation_tests(file)
	medium_expression_generation_tests(file)
	basic_tests(file)
	value_interpolation_tests(file)
	expression_interpolation_tests(file)
	advanced_expression_interpolation_tests(file)


	write(file,"""Sources: https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-ex--quote-""")

end

ll = split(read(`git ls-files --modified`, String), '\n')
if length(ll)>1
	run(`git add .`)
	run(`git commit -m "autocommit"`)
	run(`git push`)
end
#%%
