This is how I typically parse expressions. This is only here so I can point
people towards it in case they ask me about it (note: this is pseudocode,
obviously).
```d
/// Parse an expression.
///
/// The precedence is an integer; HIGHER precedence binds 
/// MORE tightly, e.g. Precedenceof (/) is GREATER than 
/// Precedenceof (+). If the precedence is 0, then the token
/// is not an operator.
///
/// This handles, binary, prefix, postfix, as well as right-
/// associative operators correctly.
Parse-Expression (precedence = 0 /** Default value is 0 **/) {
    /// Actually parse an expression depending on the current
    /// token. For instance, if the current token is `if`,
    /// call Parse-If-Expression(); if it’s the number 5,
    /// create an ‘integer literal expression’, and so on.
    ///
    /// The result of this is a variable called `lhs`.
    switch (Current-Token ()) {
        case If: lhs = Parse-If-Expression();
        ...
        case Unary Operator: {
             op = Current-Token ();
             Next-Token ();
            
             /// Call ourselves recursively, passing in the
             /// precedence of ‘op’.
             operand = Parse-Expression (Precedenceof (op));
             lhs = Make-Unary-Prefix-Expr (op, operand);
        }
    }

    /// Big binary and postfix parse loop.
    while (
        /// Recalculated on every iteration.
        op = Current-Token ();
        op-pr = Precedenceof (op);
        ra = Right-Associative? (op);

        /// Loop condition.
        (op-pr > precedence) or (op-pr == precedence and ra)
    ) do {
        /// Yeet operator.
        Next-Token ();

        /// Handle postfix operators.
        if (Postfix? (op)) {
            lhs = Make-Unary-Postfix-Expr (op, lhs);
            continue;
        }

        /// To parse a binary expression, call ourselves
        /// recursively, passing in the precedence of the
        /// current token.
        rhs = Parse-Expression (op-pr);

        /// Combine the two into a binary expression.
        lhs = Make-Binary-Expr (op, lhs, rhs);
    }
}
```
