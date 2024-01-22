

@makeex2 1 + $(sin(1))

macro makeex(arg)
           quote
               :( x = $(esc($arg)); :($x + $x) )
           end
       end

macro makeex2(arg)
           quote
               :( x = $$(Meta.quot(arg)); :($x + $x) )
           end
       end

macro makeex3(arg)
           quote
               :( x = $$(QuoteNode(arg)); :($x + $x) )
           end
       end
@makeex4 x=1 1/2 1/4
@makeex4 y=1 $y $y
@makeex5 x=1 1/2 1/4
@makeex5 y=1 $y $y
@makeex6 x=1 1/2 1/4
@makeex6 y=1 $y $y
macro makeex4(expr, left, right)
           quote
               quote
                   $$(Meta.quot(expr))
                   :($$$(Meta.quot(left)) + $$$(Meta.quot(right)))
               end
           end
       end

macro makeex5(expr, left, right)
           quote
               quote
                   $$(Meta.quot(expr))
                   :($$(Meta.quot($(Meta.quot(left)))) + $$(Meta.quot($(Meta.quot(right)))))
               end
           end
       end

macro makeex6(expr, left, right)
           quote
               quote
                   $$(Meta.quot(expr))
                   :($$(Meta.quot($(QuoteNode(left)))) + $$(Meta.quot($(QuoteNode(right)))))
               end
           end
       end


Sources: https://riptutorial.com/julia-lang/example/24364/quotenode--meta-quot--and-expr--quote-
