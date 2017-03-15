+++
draft = true
date = "2017-03-12T11:16:32-07:00"
title = "On Being Pythonic"
slug = "on_being_pythonic"
author = "Eli Uriegas"

+++

# The Zen of Python

![Zen of Python](/img/zen_of_python.png)

# What does it mean to by pythonic?

When people first start learning Python, especially coming from other languages like a Java
or a C. They have a hard time with this idea of *being pythonic*. At first, from an
outside perspective, it can seem like most python developers are just being overly
picky and that Python is just a toy language to write simple scripts in.

> And they are all right, to an extent.

To be pythonic we should look into how to improve code maintainability and ease of
development without the behavior that can lead people to not like the Python community in
the first place.

# Let's refactor some code

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
integer `n` many times.

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
Refactoring is important for maintainability and should not be discounted. Just
because something works now does not mean that it will work forever so being
able to easily discern logic is paramount.

So the next time you need to use bitwise operators maybe look at it and ask if
there is a different way to do it because chances are there really is.
