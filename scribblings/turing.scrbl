#lang scribble/manual

@title{Turing: A Turing Machine language}

@defmodulelang[turing]

@section{Introduction}

This is a domain-specific language modelled on the language Alan Turing uses in his classic 1936 paper where he introduces Turing Machines.  There are many Turing Machine implementations available, but none model the language that Turing uses very closely.  This implementation for Racket tries to get very close.

@section{Background}

In 1936, Alan Turing published a paper* that introduced Turing Machines (which he called "a-machines").  A Turing Machine is a theoretical machine that begins with a tape divided up into an infinite number of squares.  The machine has a read/write head positioned over some square, and the head may read the character on the tape at that square, write a character to the tape at that square, or erase a character on the tape at that square. Moreover, the head can move one square to the left or right.  The machine is always in one of a finite number of discrete states (called "m-configurations").

The behaviour of the Turing Machine is described in a table of instructions, which today we would call a "computer program."  Here is an example of a table of instructions (from Turing 1936, 233):
@centered{@verbatim{
Configuration               Behaviour
      m-config.      symbol     operations   final m-config.
    b           None         P0, R            c  
    c           None           R              e
    e           None         P1, R            f
    f           None           R              b}}

This table of instructions, when started with a blank tape and a Turing Machine in the @tt{b} state, will instruct the machine to print @tt{0} and @tt{1} left-to-right continuously across the tape.

In order to study the computational model presented by Turing Machines, it is advantageous to have a language that models the language in Turing's paper.  Since the machines Turing describes have an infinite tape and were (for the most part) intended to run in infinite loops, any implementation requires have some way to deal with the finitude of real-life computers.  Additionally, it is desirable to have a way to specify the initial state of the tape as well as the position of the head.

[*] Turing, Alan M.  1936.  "On Computable Numbers, with an Application to the @italic{Entscheidungsproblem,}" @italic{Proceedings of the London Mathematical Society,} Series 2, Vol. XLII, 230–65.

@section{Syntax and Semantics}

A program expressed in @tt{turing} has a @italic{header}, that allows for initialisation conditions, as well as control over the operations of the table of instructions.  A program also has a @italic{body} that encodes some table of instructions.  The goal of this domain-specific language to make the content of the body very close to the tables of instructions in Turing's paper.

@subsection{Header}

The header always consists of three lines, and should be present at the beginning of the code.  The format of the header is as follows:
@codeblock{
	#lang turing
	<tape>
	<start-state> <start-head> <start-print> <end-print>}

The first line, @tt{#lang turing}, tells Racket you are using the turing domain specific language.  This is not strictly necessary, if the language is set in DrRacket.

The second line, @tt{<tape>}, is a literal string that specifies the characters on the tape prior to entering @tt{<start-state>} and prior to carrying out any operations.  Use @tt{_} (underscore) to represent a blank square on the tape.

The third line has the following parameters: <start-state> <start-head> <start-print> <end-print>.  @tt{<start-state>} is a string representing the initial state of the machine.  @tt{<start-head>} is an integer representing the scanned square (where @tt{0} is the first square, @tt{1} is one square to the right of the first square, @tt{2} is two squares to the right of the first square, and so on).  @tt{<start-print>} is an integer representing the @tt{step} in the computation (a step is a single operation; see below) at which Racket will print the complete configuration.  @tt{<end-print>} is an integer representing the step in the computation at which Racket will stop printing subsequent complete configurations (by forcing the machine into the @italic{halt} state).

By being able to specify the characters on the tape with @tt{<tape>}, the initial state of the machine with @tt{<start-state>}, and the initial position of the head on the tape with @tt{<start-head>}, the @italic{complete configuration} of any machine at any point may be reconstructed (Turing 1936, 232).

The value for @tt{<start-print>} must be less than are equal to the value for @tt{<end-print>}.  @tt{<start-print>} is useful because it takes time for Racket to print successive complete configurations.  If some complete configurations do not need to be printed, the computation may be carried out more quickly.  @tt{<end-print>} forces the computation to halt; but the computation will do some earlier if the Turing Machine ever enters into the @italic{halt} state.

@subsubsection{Header Examples}

@bold{Example 1}

Start with a blank tape, in state @tt{b}, and have the head start on square @tt{0}.  Print output for steps @tt{0} to @tt{200}.

@codeblock{
	#lang turing
	_
	b 0 0 20}

The second line of Example 1 indicates that the tape is blank.  The third line indicates that the Turing Machine will start in state @tt{b} (first argument), with the head at position @tt{0} (second argument).  Furthermore, Racket will print complete configurations starting at step @tt{0} of the computation (third argument), and halt at step @tt{20} (fourth argument).

@bold{Example 2}

Start with a tape with the characters @tt{əə0_0}, in state @tt{begin}, and have the head start on square @tt{2}.  Print output for steps @tt{400} to @tt{500}.

@codeblock{
	#lang turing
	əə0_0
	begin 2 400 500}

The second line of Example 2 indicates that the tape starts with the characters @tt{əə0_0} written on the tape, where the first character of this string is on square @tt{0}.  The third line indicates that the Turing Machine will start in state @tt{begin} (first argument), with the head at position @tt{2}, which is the third square from the left (second argument).  Furthermore, Racket will print complete configurations starting at step @tt{400} of the computation (third argument), and halt at step @tt{500} (fourth argument).

@subsection{Body}

The body encodes some table of instructions for the Turing Machine.  The format for each line of the body is as follows (where elements are separated by a @tt{space}):

@codeblock{
	<m-config> <symbol> <ops> <final m-config>}

@tt{<m-config>}: A string representing the machine configuration that, together with @tt{<symbol>}, comprises the sufficient condition to execute the operations on this line.

@tt{<symbol>}: A single character that, together with the @tt{<m-config>}, comprises the sufficient condition to execute the operations on this line.

@tt{<ops>}: A string of comma-delimited characters representing the operations that the machine carries out if the machine is in @tt{<m-config>} and the symbol under the head is @tt{<symbol>}.  Note that because @tt{space} separates elements in the line, spaces are not permitted in @tt{<ops>}.

@tt{<final m-config>}: The machine configuration assumed after the operations are carried out.

The elements @tt{<m-config>} and @tt{<symbol>} function as a sufficient condition for executing the @tt{<ops>} and the machine going into configuration @tt{<final m-config>}.  If @tt{<m-config> <symbol>}, is not unique in the table of instructions, only the first occurrence of the instruction may be acted upon.

@subsubsection{Configurations}

Configurations are strings of symbols without spaces.  The only special configuration is @tt{halt}, which may be put as a final m-config on a line in the table of instructions.  If the machine ever goes into the @tt{halt} state, it halts immediately.  When the machine halts due to a configuration (as opposed to hitting @tt{<stop-print>} as specified in the header), Racket prints @tt{halt} as the final line of the computation.  There is no equivalent to the @tt{halt} configuration in Turing's paper.

@subsubsection{Symbols}

Valid symbols are any single character, with two exceptions: @tt{*} and @tt{_} (underscore).  The @tt{*} symbol has special meaning, and thus cannot appear on the tape: it matches any symbol on the tape other than @tt{_} (underscore).  It is the equivalent of the "Any" symbol in Turing's paper, which is intended to match any symbol other than a blank (Turing 1936, 234).  Because of this behaviour, @tt{_} represents a blank, and corresponds to the "None" symbol in Turing's paper.

If the body has multiple matches for @tt{<symbol>} with some @tt{<m-config>}, precedence is given to the line which appears earlier.  This may comes into play when using @tt{*}, since it is often desirable to match specific symbols, and then use @tt{*} to catch any remaining symbols other than @tt{_} (underscore).  In such a case, be sure the specific symbols are above @tt{*} in the body for that configuration.

@subsubsection{Operations}

Valid operations are @tt{R, L, P<symbol>, E}, and work as follows:

@tt{R}: Move the head one square to the right of the current square.

@tt{L}: Move the head one square to the left of the current square.

@tt{P<symbol>}: Print @tt{<symbol>} on the current square.  This overwrites any symbol under the head.  @tt{<symbol>} is any single character.  Note that @tt{P<symbol>} does not automatically move the head left or right after printing.

@tt{E}: Erase the symbol on the current square.  This is equivalent to @tt{P_} (print blank).

@subsubsection{Table of Instructions Example}

@bold{Example 3}

Assuming the machine has a blank tape and starts in state @tt{b}, print @tt{01010101…} across the tape.

@codeblock{
	b _ P0,R c
	c _ R e
	e _ P1,R f
	f _ R b}

@tt{b _ P0,R c}: If the machine is in configuration @tt{b}, and the head is on a blank (@tt{_}, underscore) square, then print @tt{0} in that square and move the head one square to the right, and go into configuration @tt{c}.

@tt{c _ R e}: If the machine is in configuration @tt{c}, and the head is on a blank square (@tt{_}, underscore), then move the head one square to the right, and go into configuration @tt{e}.

@tt{e _ P1,R f}: If the machine is in configuration @tt{e}, and the head is on a blank (@tt{_}, underscore) square, then print @tt{1} in that square and move the head one square to the right, and go into configuration @tt{f}.

@tt{f _ R b}: If the machine is in configuration @tt{c}, and the head is on a blank square (@tt{_}, underscore), then move the head one square to the right, and go into configuration @tt{b}.

The output of a machine running this table of instructions is @tt{0_1_0_1_0_1_0_1_}…, and the head is on square 38 at step @tt{200}.

@bold{Example 4}

Assuming the machine has a blank tape and starts in state @tt{b}, print @tt{0_1} and then halt.

@codeblock{
b _ P0,R c
c _ R e
e _ P1 halt

Example 4 demonstrates the use of @tt{halt} as the final m-configuration. It follows the same pattern as Example 3, except that instead of going into an infinite loop, the machine goes into a halt state.

The output of a machine running this table of instructions is @tt{0_1}, and the head is on square 2 when the machine halts.

@subsubsection{Comments}

Any line prefixed with @tt{;} is treated as a comment.  That is, everything that follows to the right of @tt{;} on the line is ignored.

@section{A Complete Example}

@bold{Example 5}

Write a header for a blank tape, with a machine starting in state @tt{b} and the head on the first square, and printing output for steps @tt{0} to @tt{200} before halting.  Write a body where the machine prints the following pattern:

@codeblock{əə0_0_1_0_1_1_0_1_1_1_0_1_1_1_1_0_1_1_1_1…}

@codeblock{
;; Start with a blank tape
_
;; Start in machine configuration b, with the head on square 0.
;; Print the first 200 steps of the computation.s
b 0 0 200
;; Table of instructions
b _ Pə,R,Pə,R,P0,R,R,P0,L,L o
o 1 R,Px,L,L,L o
o 0 _ q
q * R,R q
q _ P1,L p
p x E,R q
p ə R f
p _ L,L p
f * R,R f
f _ P0,L,L o}

Example 5 is taken from Turing's paper ("Example II"; 1936, 234).  The first line of the table of instructions sets up the tape by printing symbols, resulting in @tt{əə0_0}.  Then the machine goes into configuration @tt{o}, and starts the main loop.

This example table of instructions tells the machine to print @tt{0} followed by a single @tt{1}, then a @tt{0} followed by two @tt{1}s, then a @tt{0} followed by three @tt{1}s, and so on.

Notice that this table of instructions follows Turing's original very closely, with a few exceptions.  @tt{*} is used in place of "Any"; @tt{_} is used in place of "None"; and all spaces have been removed from comma-delimited operations.
