PredicateOptimiser
==================

PredicateOptimiser is all about doing cool things with `NSPredicate` objects. There are two classes:

- `POPredicateOptimiser` This class can be used to optimise your `NSPredicate` object.
- `POPredicateFormatter` This class can be used to format your `NSPredicate` object.

POPredicateOptimiser
--------------------

`POPredicateOptimiser` has a single method `optimisedPredicateForPredicate:`. Passing it an `NSPredicate` object will return you a new (possibly optmised) `NSPredicate` object in accordance property `optimisationType`.

`optimisationType` takes one of the following values:

- `POPredicateOptimisationTypeNone` The optimiser will simply return a copy of the `NSPredicate` object.
- `POPredicateOptimisationTypeBest` The optimiser will do its best to optimise the `NSPredicate` object.

For example:

| Before | After |
|-------|-------|
| `not (a > b)`   | `a <= b`   |
| `... OR TRUEPREDICATE OR ...` | `TRUEPREDICATE` |
| `... AND FALSEPREDICATE AND ...` | `FALSEPREDICATE` |

POPredicateFormatter
--------------------

`POPredicateFormatter` has a single method `stringFromPredicate:`. Passing it an `NSPredicate` object will return you an `NSString` in accordance with the property `displayType`.

`displayType` takes one of the following values:

- `POPredicateDisplayTypeString` The formatter will simply return the result of calling `description` on the `NSPredicate` object.
- `POPredicateDisplayTypeCocoa` The formatter will return an `NSString` containing the code neccessary to reproduce the `NSPredicate` object in code.

For example, `string contains[cd] 'Foo'` would produce:

```objectivec
[NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionWithFormat:@"string" /* NSKeyPathExpression */rightExpression:[NSExpression expressionWithFormat:@""Foo"" /* NSConstantValueExpression */ modifier:NSDirectPredicateModifier type:NSContainsPredicateOperatorType options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption]
```

License
-------

The license for the code is included with this project; it's basically a BSD license with attribution.

John Scott
http://jjrscott.com/