
DefaultBehavior Definitions dmacro = syntax(
"takes one optional documentation string, and one or more
arguments. these argument should all begin with a literal array.
This literal array will be interpreted as a destructuring
pattern. the syntax macro will expand into a macro that will read
dispatch based on all the patterns given. the first pattern
that matches will be used. the code coming after the literal
array will have access to the variables defined in the pattern.
the result of this code will be the result of the macro.

if no patterns match, a Condition Error Invocation condition
will be signalled.

the patterns can take several basic forms. the first form is 
that of a simple name, like this:

  [arg]

this pattern will match exactly one argument, and assign that
argument message to the name 'arg'. this message will not be
evaluated.

a pattern can have several arguments like this:

  [one, two, three]

this pattern will match exactly three arguments and assign them
to the names 'one', 'two' and 'three', unevaluated.

if you wish to evaluate an argument before it gets assigned
to the variable, you can use a literal > preceding the name,
like this:

  [one, >two]

this will take exactly two arguments, where the second will be
assigned the evaluated result of the second argument while the
first will get the unevaluated message.

the evaluation of evaluated arguments are lazy, which means that
something like this:

  [>cond, then] ;; do something here
  [>cond, then, else] ;; do something else

will only evaluate the cond that is relevant to the structure.
this means that if you give two arguments to the above code, only
the above cond will be evaluated. and if you give three arguments
only the second cond will be evaluated.

the final destructuring available at the moment allows the use of a
rest argument. this should generally be placed last in the patterns
since a rest argument will most of the time match everything.

a rest argument can be specified with

  [+any]

the plus sign is the magic part. any name can be used. what you will
get is a list of unevaluated messages matching zero or more of the
argument list. rest arguments can be combined with other arguments
but should be placed last in that case.

a list of evaluated arguments can be generated by following the plus
sign with a greater than arrow:

  [arg, +>moreArgs]

a pattern matching list can also be empty.

finally, a destructuring can also have default arguments. these will
be evaluated if no matching argument can be found. the default argument
for an unevaluated argument will be the message chain to unevaluated
set to the default argument. the default argument for an evaluated
value will be evaluated at the point, which means it can use earlier
values:

  [arg1 2+2, >arg2 2+2]

will match an empty argument list, and in that case give arg1 the 
message chain corresponding to 2+2, while arg2 will be set to the
value 4."

  docstring = nil
  args = call arguments
  if((args length > 1) && (args[0] name == :"internal:createText"),
    docstring = args[0]
    args = args[1..-1])

  min = 0
  max = 0

  val = '(argCount = call arguments length)
  inner = 'cond
  (val last -> '.) -> inner

  defs = DefaultBehavior Definitions
  args each(arg,
    defs cell(:dmacro) generatePatternMatch(arg arguments, inner)
    assigns = defs cell(:dmacro) generateAssigns(arg arguments, inner)
    assigns -> arg next
  )

  inner << '(error!(Condition Error Invocation NoMatch, message: call message, context: call currentContext))

  m = 'macro
  if(docstring, m << docstring)
  m << val
)

DefaultBehavior Definitions cell(:dmacro) generatePatternMatch = method(thePattern, where,
  minAndMax = patternMinAndMax(thePattern)

  if(minAndMax first == minAndMax second,
    first = '(argCount ==)
    first last << `(minAndMax first)
    where << first,
    if(minAndMax second == -1,
      if(minAndMax first == 0,
        where << 'true,

        first = '(argCount >=)
        first last << `(minAndMax first)
        where << first),

      first = '(argCount >=) 
      first last << `(minAndMax first)
      second = '(argCount <=)
      second last << `(minAndMax second)
      (first last -> '(&&)) << second
      where << first)))

DefaultBehavior Definitions cell(:dmacro) patternMinAndMax = method(pattern,
  min = 0
  max = 0
  pattern each(p,
    if((p name == :"+") || (p name == :"+>"),
      max = -1,
      max++
      optional = ((p name == :">") && (p arguments first next)) || p next
      unless(((p name == :">") && (p arguments first next)) || p next,
        min++)))
  min => max
)

DefaultBehavior Definitions cell(:dmacro) generateAssigns = method(thePattern, where,
  DB = DefaultBehavior
  head = DB message(".")
  where << head
  current = head
  index = 0
  thePattern each(arg,
    name = arg name
    evaluateArg = false
    restArg = false
    optional = false
    if(arg arguments length > 0,
      if(name == :">",
        evaluateArg = true
        if(arg arguments first next,
          optional = it),
        if(name == :"+",
          restArg = true,

          evaluateArg = true
          restArg = true))
      name = arg arguments first name,
      if(arg next,
        optional = it))
    
    assgn = DB message(:"=")
    assgn << DB message(name)
    if(restArg,
      assgnPart = '(call arguments [])
      ix = `index
      ix -> '(..(-1))
      assgnPart last << ix
      if(evaluateArg,
        assgnPart last -> '(map(evaluateOn(call ground, call ground))))
      assgn << assgnPart,

      if(optional,
        useOpt = '(argCount <=)
        useOpt last << `index
        theTest = 'if
        theTest << useOpt

        assgnPart = if(evaluateArg,
          optional,
          DB message(:"'") << optional)
        theTest << assgnPart

        assgnPart = if(evaluateArg,
          '(call argAt),
          '(call arguments []))
        assgnPart last << `(index)
        theTest << assgnPart
        assgn << theTest,
 
        assgnPart = if(evaluateArg,
          '(call argAt),
          '(call arguments []))
        assgnPart last << `(index)
        assgn << assgnPart))

    current = ((current -> assgn) -> '.)
    index++
  )
  current last
)
