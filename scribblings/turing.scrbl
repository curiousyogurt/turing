#lang scribble/manual

@title{Turing: A Turing Machine language}

@defmodulelang[turing]

@section{Introduction}

This is a domain-specific language.

This is a domain-specific language for Turing Machines modelled on the language Alan Turing uses in his classics 1936 paper where he introduces Turing Machines.There are many Turing Machine implementations available, but none model the language that Turing uses.  This implementation for Racket gets very close.

@section{Background}

In 1936, Alan Turing published a paper[1] that introduced Turing Machines (which he called "a-machines").  A Turing Machine is a theoretical machine beginning with a tape divided up into an infinite number of squares.  The machine has a read/write head that is positioned over some square, and the head may read the character on the tape at that square, write a character to the tape at that square, or erase a character on the tape at that square. Moreover, the head can move one square to the left or right.  The machine is always in one of a finite number of states (called "m-configurations").

The behaviour of the Turing Machine is described in a table of instructions, which today we would call a "computer program."  Here is an example of a table of instructions (from Turing 1936, 233):
@centered{@verbatim{
Configuration               Behaviour
      m-config.      symbol     operations   final m-config.
    b           None         P0, R            c  
    c           None           R              e
    e           None         P1, R            f
    f           None           R              b}}

This table of instructions, when started with a blank tape and a Turing Machine in the @tt{b} state, will print @tt{0} and @tt{1} left-to-right continuously across the tape.

[1] Turing, Alan M.  1936.  "On Computable Numbers, with an Application to the @italic{Entscheidungsproblem,}" @italic{Proceedings of the London Mathematical Society,} Series 2, Vol. XLII, 230–65.