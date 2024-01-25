include("README_generation_fn.jl")

isdir("./JuliaMacroCheatSheet") && cd("./JuliaMacroCheatSheet")

open("README.md", "w") do file
	basic_tests(file)
	value_interpolation_tests(file)
	expression_generation_tests(file)
	expression_interpolation_tests(file)
	advanced_expression_interpolation_tests(file)
end

@show pwd()
ll = split(read(`git ls-files --modified`, String), '\n')
println(ll)
@show ll
if length(ll)>0
	run(`git add .`)
	run(`git commit -m "autocommit"`)
	run(`git push`)
end
