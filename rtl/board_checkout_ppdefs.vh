// metaprogramming bullshit to deal with preprocessor not being able to do math
// DONT TOUCH
`define BSV_DEFINEIT(d) d \

// newline above is important
// Define a macro if not zero.
`define DEFINE_IF( d , n )              \
    `undef d                            \
    `ifndef _BSV_DEFIF_Z_``n            \
        `BSV_DEFINEIT( `define d n )    \
    `endif

`define _BSV_DEFIF_Z_0    
// Return a macro, or 0 if not defined.
`define IF_DEFINED_ELSE_Z( d ) `ifdef d `d `else 0 `endif

// END DONT TOUCH
