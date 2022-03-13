#  Code Generation

## Why is code generation needed?

This library requires a lot of near-duplicated code to implement.  Many methods are near identical except there is a difference of async, throws, or @escaping.  For `.then` there are also differences of whether the body returns a value or not. 

In order to keep the code readible, flexible, and free of duplication typos, a simple code generation (CG) system is used, based on running find-and-replace on method bodies and signatures.  In particular, this helps with implementation of Then.swift, which would be highly unweildy without CG.  Care has been taken to avoid overusing CG in too many places, so that the code can remain readible.  

## Why is this in the `Tests` directory?

I wanted the Swift code for the CG engine to have syntax highlighting and be accessible from the same Xcode project, but not be included in the bundle when this package is installed as a 3rd party.  The Tests directory seems like a safe place for this kind of code.

I couldn't find a way of getting code generation to run on every build in Xcode, so instead it is runnable as a "test" (even though it is not a test).  To run code generation, just click the play button in the `CodeGeneration.swift` file, and hit "Switch and run tests", or switch the scheme yourself and run the "test".

## How does it work?

* Generated code is added to each top-level declaration that requires code generation, between `// GENERATED` and `// END GENERATED` (these comments are added if they do not exist already).

* Inside a top-level declaration, you can use code generation by first defining a pattern using:

	```swift
	// pattern:myPattern
	<code>
	// endpattern
	```

* Then you can use this pattern to generate code in the same top-level declaration with `// generate`

	```swift
	// pattern:myPattern
	<code>
	// endpattern
	
	// generate:myPattern(find1 => replace1, find2 => replace2)
	```

	Within the parentheses you can define substitution rules. They must be separated by comma-space (`, `), just like the `=>` operation must have spaces on both sides.

	The example above does not only look for the literal `find1` and `find2` but also `// find1`, `// find2`, `/* find1 */`, and `/* find2 */`. An error is raised if any of the finds are not found. To make the find-replace rule optional you can use `?=>` rather than `=>`. To treat the find expression as a regex, use `R=>`, and `R?=>` (although using regex too much will hurt readability).

*  Certain find-replace patterns appear together frequently, so you can group them into a ruleset with `// ruleset`. As of now, all rulesets are global no matter where they are defined (as opposed to everything else which is scoped to the containing top-level declaration (TLD)).  To define a global ruleset use:

	```swift
	// ruleset:myRuleset(find1 => replace1, find2 => replace2)
	```

	Then you can use it among find-replace patterns e.g.

	```swift
	// generate:myPattern(find1 => replace1, myRuleset, find2 => replace2, myOtherRuleset)
	```

	Rulesets can use other rulesets in their definitions.

* There is a special ruleset that is available in a TLD. It is called `...`. It is expanded to whatever rules/replacements were defined in the last call to `// generate`. Use this to pile on further replacements to the previously-generated result.

## Why not use Sourcery?

Sourcery was tried and it failed.  It cannot handle complicated function signatures, such as two functions that are overloaded with different return types, or (more relevant to our case) overloaded with different `async` or `throws` intricacies.

