
#%%
a=1
macro ✖(ex); :($ex); end         
macro ✓(ex); :($(esc(ex))); end   
# macro ✓(ex); :($(QuoteNode(ex))); end   
eval(        :(a=2))             # a=2
# eval(        :($(esc(a=3))))     # ERROR: MethodError: no method matching esc(; b::Int64)
@✖ a=4                           # a=2
@✓ a=5                           # a=5
display(@macroexpand @✖ a=4)     # :(var"#54#a" = 4)
display(@macroexpand @✓ a=5)     # :(a = 5)
a


#%%
using Base.Meta: quot, QuoteNode

macro ✖(va, ex); :($va=$ex); end 
macro ✓(va, ex); :($(esc(va))=$(esc(ex))); end 
@✖ a 5
@✓ a 6
display(@macroexpand @✖ a 5)
display(@macroexpand @✓ a 6)