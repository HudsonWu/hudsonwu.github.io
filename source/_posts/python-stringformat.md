---
title: python3中的字符串格式化
date: 2020-03-01 20:11:41
categories:
- Code
tags:
- python
thumbnail: /gallery/code01.png
---

有三种字符串格式化的方式：`%-formatting`、`str.format()`（python 2.6引入）、`f-strings`（python 3.6引入）。

## %-formatting

这是python语言一开始就支持的格式化方式，这种格式不是很好，因为它很冗长，并且会导致错误，比如没有正确地显示元组或字典，官方不推荐使用。

```python
>>> name = "Eric"
>>> "Hello, %s." % name
'Hello, Eric.'
```

插入多个变量：
```python
>>> name = "Eric"
>>> age = 74
>>> "Hello, %s, You are %s." % (name, age)
'Hello, Eric, You are 74.'
```

当开始使用多个参数和更长的字符时，代码就会变得不容易阅读了：
```python
>>> first_name = "Eric"
>>> last_name = "Idle"
>>> age = 74
>>> profession = "comedian"
>>> affiliation = "Monty Python"
>>> "Hello, %s %s. You are a %s. Your were a member of %s." % (first_name, last_name, age, profession, affiliation)
'Hello, Eric Idle. You are 74. You are a comedian. You were a member of Monty Python.'
```

## str.format()

str.format()是对%-formatting的该进，它使用普通的函数调用语法，并且可以通过__format__()方法将对象转换为字符串。

```python
>>> "Hello, {}. You are {}.".format(name, age)
'Hello, Eric. Your are 74.'
```

可以使用索引：
```python
>>> "Hello, {1}. You are {0}.".format(age, name)
'Hello, Eric. Your are 74.'
```

可以使用变量名：
```python
>>> person = {'name': 'Eric', 'age': 74}
>>> "Hello, {name}. You are {age}.".format(name=person['name'], age=person['age'])
'Hello, Eric. Your are 74.'
```

字典使用小技巧 - `**`：
```python
>>> "Hello, {name}. You are {age}.".format(**person)
'Hello, Eric. Your are 74.'
```

使用str.format()比使用%-formatting更容易阅读，但在处理多个参数和更长的字符串时，仍然显得冗长：
```python
>>> first_name = "Eric"
>>> last_name = "Idle"
>>> age = 74
>>> profession = "comedian"
>>> affiliation = "Monty Python"
>>> print(("Hello, {first_name} {last_name}. You are {age}. " + 
>>>        "You are a {profession}. You were a member of {affiliation}.") \
>>>        .format(first_name=first_name, last_name=last_name, age=age, \
>>>                profession=profession, affiliation=affiliation))
'Hello, Eric Idle. You are 74. You are a comedian. You were a member of Monty Python.'
```

## f-strings

f-strings语法和str.format类似，但更简洁：
```python
>>> name = "Eric"
>>> age = 74
>>> f"Hello, {name}. You are {age}."
'Hello, Eric. Your are 74.'
>>> F"Hello, {name}. You are {age}."
'Hello, Eric. Your are 74.'
```

因为f-strings是在运行时求值的，所以可以再其中放入任何有效的表达式：
```python
>>> f"{2 * 37}"
'74'
>>> def to_lowercase(input):
...     return input.lower()

>>> name = "Eric Idle"
>>> f"{to_lowercase(name)} is funny."
'eric idle is funny.'
>>> f"{name.lower()} is funny."
'eric idle is funny.'
```

还可以使用对象：
```python
class Comedian:
    def __init__(self, first_name, last_name, age):
        self.first_name = first_name
        self.last_name = last_name
        self.age = age
    def __str__(self):
        return f"{self.first_name} {self.last_name} is {self.age}."
    def __repr__(self):
        return f"{self.first_name} {self.last_name} is {self.age}. Surprise!"
```

```python
>>> new_comedian = Comedian("Eric", "Idle", "74)
>>> f"{new_comedian}"
'Eric Idle is 74.'
```

`__str__()`和`__repr__()`方法的作用是将对象表示为字符串，在类定义中需要确保至少包含其中一个。由`__str__()`返回的字符串是对象的非正式字符串表示，应该是可读的，由`__repr__()`返回的字符串时官方表示，应该是明确的，直接调用`str()`和`repr()`比使用`__str__()`和`__repr__()`更好。

f-strings默认使用`__str__()`，可以使用`!r`转换标志确保使用`__repr__()`：
```
>>> f"{new_comedian!r}"
'Eric Idle is 74. Surprise!'
```

### 多行字符串

```python
>>> name = "Eric"
>>> profession = "comedian"
>>> affiliation = "Monty Python"
>>> message = (
...     f"Hi {name}. "
...     f"You are a {profession}. "
...     f"You were in {affiliation}."
... )
>>> message
'Hi Eric. You are a comedian. You were in Monty Python.'
```

还可以使用`\`来多行扩展字符串：
```python
>>> message = f"Hi {name}. " \
...           f"You are a {profession}. " \
...           f"You were in {affiliation}."
...
>>> message
'Hi Eric. You are a comedian. You were in Monty Python.'
```

如果使用三引号`"""`，可能不一定是你想要的：
```python
>>> message = f"""
...     Hi {name}. 
...     You are a {profession}. 
...     You were in {affiliation}.
... """
...
>>> message
'\n    Hi Eric.\n    You are a comedian.\n    You were in Monty Python.\n'
```

### 执行时间

f-strings比另外两种方式都更快，f-strings是在运行时计算的表达式，而不是常量值。

```python
>>> import timeit
>>> timeit.timeit("""name = "Eric"
... age = 74
... '%s is %s.' %(name, age)""", number = 10000)
0.0032246080227196217
```

```python
>>> timeit.timeit("""name = "Eric"
... age = 74
... '{} is {}.'.format(name, age)""", number = 10000)
0.004390567017253488
```

```python
>>> timeit.timeit("""name = "Eric"
... age = 74
... f'{name} is {age}.'""", number = 10000)
0.0022761650034226477
```

### 一些细节

```python
>>> f"{'Eric Idle'}"
'Eric Idle'
>>> f"The \"comedian\" is {name}, aged {age}."
'The "comedian" is Eric Idle, aged 74.'
>>> f"{\"Eric Idle\"}"
  File "<stdin>", line 1
    f"{\"Eric Idle\"}"
                      ^
SyntaxError: f-string expression part cannot include a backslash
```

```python
>>> comedian = {'name': 'Eric Idle', 'age': 74}
>>> f"The comedian is {comedian['name']}, aged {comedian['age']}."
The comedian is Eric Idle, aged 74.
```

```python
>>> f"{{74}}"
'{74}'
>>> f"{{{74}}}"
'{74}'
>>> f"{{{{74}}}}"
'{{74}}'
```

## 一些说明

python中有两个内建方法（functions）可以将对象转换成字符串：`str`和`repr`，`str`是更加友好、可读的字符串输出，`repr`则是包括对象更详细的信息。

```python
>>> print(repr('hi'))
'hi'
>>> print(str('hi'))
hi
>>> print('hi')
hi
```

```python
class Foo:
    def __init__(self, foo):
        self.foo = foo

    def __eq__(self, other):
        """Implements ==."""
        return self.foo == other.foo
    
    def __repr__(self):
        # if you eval the return value of this function,
        # you'll get another Foo instance that's == to self
        return "Foo(%r)" % self.foo
```

## 引用

+ [Python 3's f-Strings](https://realpython.com/python-f-strings/)
