+++
Tags = [
  "Development",
  "Python"
]
Categories = [
  "Development",
  "Python"
]
date = "2016-12-18T13:17:57-07:00"
title = "contextlib in Python3"
Description = ""
draft = true

+++

# What is contextlib?
`contextlib` is a library in python that provides helpers to 
easily create functions that that have some sort of *opening* 
and *closing* context (we call these **context managers**) 
that help the alleviate the user of having to do extra actions.

For users who have already used `contextlib` in python2 you can
skip ahead past these basic examples.

## An example of *context*
In most programming languages you see the same ideas when it 
comes to dealing with the files. 

The process for opening files in most programming languages is 
usually as follows:

1. Open the filehandler with some sort of **open** function
2. Do the operation you want to the file (Usually a read or a write)
3. Cleanup the filehandler with some sort of **close** function

In Python we can deal with steps 1 & 2 in one swoop using something 
called a *context manager* which gives us the advantage of not having 
to rely on anyone to do our cleanup for us.

### Written without a **context manager**
```python
fh = open('my_file', 'r')
data = fh.read()
fh.close()
```

### Written with a **context manager**
```python
with open('my_file', 'r') as fh:
    data = fh.read()
```

## Why is *context* important?
So for things that need cleanup, a *context manager* allows us to not have 
to worry about calling any close or cleanup functions. Now for people 
coming from Python 2 you might be saying:

> Well we already had this type of functionality with Python 2's contextlib
what's so great about the Python 3 version of it?

# contextlib in Python3

There are a lot of cool features in Python 3's version of contextlib but 
I will only be going over the ones that could use a bit more explanation 
than the standard documentation.

## contextlib.redirect_std[out|err]

A lot of times when you are needing to test an application you need to test 
against the output of said application but you may find yourself in a 
situation where the developer has only directed all of their output into 
stdout. In most cases you could use 
[unittest.mock](https://docs.python.org/3/library/unittest.mock.html) to mock
`sys.stdout` to some StringIO but this type of monkeypatching only solves for
some situations. However in Python3 this can now be acheieved with the use of 
Python 3's `contextlib.redirect_stdout` and `contextlib.redirect_stderr`.

If you are using `pytest` this functionality can be acheived with 
the [capsys](http://doc.pytest.org/en/latest/capture.html) fixture.

### Example:

```python
import contextlib
import io
import unittest2

class ApplicationOutput(unittest2.TestCase):

    def test_help_output(self):
        captured_output = io.StringIO()
        with contextlib.redirect_stdout(captured_output):
            # Run some part of your application
            print('Dummy application output')
        self.assertEqual(
            captured_output.getvalue(), 'Dummy application output\n')

    def test_error_message(self):
        captured_output = io.StringIO()
        with contextlib.redirect_stderr(captured_output):
            # Run some part of your application
            print('Dummy application error')
        self.assertEqual(
            captured_output.getvalue(), 'Dummy application error\n')
```

## contextlib.ExitStack
So if you've started to try and mess with golang you see one of the very cool
features of is it's use of this keyword called `defer`. Here's an example of it 
in action:

```go
package main
import "fmt"
func main() {
    // Don't execute this until the end of the function
    defer fmt.Println("world")

    fmt.Println("hello")
    // Output ->
    // hello\n
    // world\n
}
```

In python 3 we can do this same sort of action using the `contextlib.ExitStack` 
context manager!

### Example:

