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
