include("README_generation_fn.jl")


open(pwd()*"/JuliaMacroCheatSheet/README.md", "w") do file
	value_interpolation_tests(file)
	expression_generation_tests(file)
	expression_interpolation_tests(file)
end


