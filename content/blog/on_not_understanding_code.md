+++
date = "2017-03-16"
title = "On not understanding code"
author = "Eli Uriegas"

+++

# Figuring out code that seems mysterious
We all come across code that seems to not make sense in what it does. Whether it's new
syntax, black hole logic (logic that doesn't seem to make any sense), or *enterprise
legacy code*, the feeling of not knowing how code works is aggravating. But alas, there
are simple things we can do to remedy that.

In this post I'll be going over a function that didn't make a whole lot of sense to me
when I first read through it, how I dissected the function, and how I eventually rewrote
it to make more sense to those who come after. I'll be heavily using an interpreter to
figure out what different things do (like most Python developers should be doing) and if
you don't have a preference I would absolutely recommend
[ptpython](/blog/why-ptpython-is-the-only-repl-you-will-ever-need/).

*Disclaimer: I do not have a background in embedded so the usage of bitwise operators was
pretty foreign to me before this exercise, I'm also not going to pretend like I understand
all of the math in this example either*

## Our coding example:
So the below code tries to implement the Russian Peasant Algorithm that reduces exponent
calculation to `O(log(n))`. It takes a very basic approach where we try to stay as close as
possible to a provided C/C++ example.

```python
def my_pow(x, y):
    P = 1
    while y > 0:
        if y & 1:
            P = P * x
        x = x * x
        y = y >> 1
    return P
```

This example heavily utilizes bitwise operators, like those that are done in the C/C++
example. Bitwise operators, in my opinion, can be confusing to those coming into a code
base and should be avoided at all possible. Let's take a look into a debugger and see
what those actually do.

If you're really interested in the low level interpretations of bitwise operators I
would recommend the [wikipedia article](https://en.wikipedia.org/wiki/Bitwise_operation).
But if you're like me and you just want to understand code as fast as possible read on!

## The `&` Operator

### What does it do?
When put through an interpreter the bitwise `and` operator `&` looks somewhat similar
to this:

```python
In [17]: 5 & 1
Out[17]: 1

In [18]: 4 & 1
Out[18]: 0
```

Notice a pattern? If not it's okay, I'll provide another example.

```python
In [19]: for num in range(1, 20):
       2     print(num, num & 1)
1 1
2 0
3 1
4 0
5 1
6 0
7 1
8 0
9 1
10 0
11 1
12 0
13 1
14 0
15 1
16 0
17 1
18 0
19 1
```

Notice it now? It appears that bitwise `and` for integers returns
a `1` when the number is odd and a `0` when the number is even.

### Replacing it with something more readable
Let's replace it with the *modulo* operator `%`, which just gives us
the remainder of the ensuing division operation. For example, if we
did `5 % 2` the return value would be `1` since `1` is leftover
after dividing `5` by `2`.

Replacing it in our function would look similar to:
```python
def my_pow(x, y):
    P = 1
    while y > 0:
        if y % 2:  # We have a remainder after dividing by 2!
```

## The `>>` Operator

### What does it do?
The `>>` operator stands for bitwise shift in that it will shift an
integer `n` many times. For a more in depth explanation see this
[stackoverflow answer](http://stackoverflow.com/a/141873)

Let's put this into an interpreter and see if we can see a pattern as well.

```python
In [12]: 5 >> 1
Out[12]: 2


In [13]: 4 >> 1
Out[13]: 2
```

The pattern here is a little bit harder to discern. We'll write some code like
we did before to discern it.

```python
In [14]: for num in range(1, 20):
       2     print(num, num >> 1)
1 0
2 1
3 1
4 2
5 2
6 3
7 3
8 4
9 4
10 5
11 5
12 6
13 6
14 7
15 7
16 8
17 8
18 9
19 9
```

See it yet? It appears as though the `>>` operator when given a `1` as `n` does an
operation similar to dividing the input integer by `2` then rounding downwards.
Luckily in Python the operator `//` does exactly that!

### Replacing it with something more readable

```python
def my_pow(x, y):
    P = 1
    while y > 0:
        if y % 2:
            P = P * x
        x = x * x
        y = y // 2
    return P
```

## Are we done refactoring yet?

Now looking at the code and having a basic knowledge of most of the operators you
could say that this code is perfect and doesn't require any more work. But this is
Python and there's being Pythonic on top of that! So let's get it even shorter!

### Not repeating ourselves
So in our function we have a lot of statements that boil down to similar pattern:

```
a = a <operator> b
```

In Python we can shorten these statements like so:

```
a <operator>= b
```

So let's try it out with our function

```python
def my_pow(x, y):
    P = 1
    while y > 0:
        if y % 2:
            P *= x
        x *= x
        y //= 2
    return P
```

Looks pretty good, maintainability may be creeping away since some developers
coming in might not know the `a <operator>= b` syntax but it does borrow from
some other languages so the overlap may be there!

# Conclusion
Understanding code is easy when we break down individual components and try to discern
patterns based on inputs we already know. When a problem seems hard to solve, bisect it
and see if it's easier when put into nice bite size pieces. Unfortunately not all
problems can be solved like this and I'll go over how to solve problems that are a bit
more involved when I go over my favorite debugging tool:
[PUDB](https://github.com/inducer/pudb)
