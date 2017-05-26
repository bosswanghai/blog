# lpeg使用

### 简介
lua的正则表达式库

[doc](http://www.inf.puc-rio.br/~roberto/lpeg/#download)

### 规则

lpeg可以创造和组合规则

操作符          | 描述
-------------- | ---
lpeg.P(string) | Matches string literally
-------------- | ---
lpeg.P(n)      | Matches exactly n characters
-------------- | ---
lpeg.S(string) | Matches any character in string (Set)
-------------- | ---
lpeg.R("xy")   | Matches any character between x and y (Range)
-------------- | ---
patt^n         | Matches at least n repetitions of patt
-------------- | ---
patt^-n        | Matches at most n repetitions of patt
-------------- | ---
patt1 * patt2  | Matches patt1 followed by patt2
-------------- | ---
patt1 + patt2  | Matches patt1 or patt2 (ordered choice)
-------------- | ---
patt1 - patt2  | Matches patt1 if patt2 does not match
-------------- | ---
-patt          | Equivalent to ("" - patt)
-------------- | ---
`#patt`  | Matches patt but consumes no input
-------------- | ---
lpeg.B(patt)   | Matches patt behind the current position, consuming no input


LPeg also offers the `re module`, which implements patterns following a regular-expression style (e.g., [09]+). (This module is 260 lines of Lua code, and of course it uses LPeg to parse regular expressions and translate them to regular LPeg patterns.)

### 使用

##### 函数功能

1. lpeg.match (pattern, subject [, init])

pattern

subject

init   指定subject的开始位置

`ret` 返回匹配的字符串后面字符的位置

2. lpeg.type (value)

`ret = "pattern" if value == pattern else nil`


3.lpeg.version ()

`ret` string of lpeg


4. lpeg.setmaxstack (max)

The default limit is 400

##### 构造pattern

1. lpeg.P (value)

返回值根据value输入模式确定

```
Converts the given value into a proper pattern, according to the following rules:

If the argument is a pattern, it is returned unmodified.

If the argument is a string, it is translated to a pattern that matches the string literally.

If the argument is a non-negative number n, the result is a pattern that matches exactly n characters.

If the argument is a negative number -n, the result is a pattern that succeeds only if the input string has less than n characters left: lpeg.P(-n) is equivalent to -lpeg.P(n) (see the unary minus operation).

If the argument is a boolean, the result is a pattern that always succeeds or always fails (according to the boolean value), without consuming any input.

If the argument is a table, it is interpreted as a grammar (see Grammars).

If the argument is a function, returns a pattern equivalent to a match-time capture over the empty string.
```

2. lpeg.B(patt)

```
Returns a pattern that matches only if the input string at the current position is preceded by patt. Pattern patt must match only strings with some fixed length, and it cannot contain captures.

Like the and predicate, this pattern never consumes any input, independently of success or failure
```

3. lpeg.R ({range})

```
Returns a pattern that matches any single character belonging to one of the given ranges. Each range is a string xy of length 2, representing all characters with code between the codes of x and y (both inclusive).

As an example, the pattern lpeg.R("09") matches any digit, and lpeg.R("az", "AZ") matches any ASCII letter.


```

4. lpeg.S (string)

```
Returns a pattern that matches any single character that appears in the given string. (The S stands for Set.)

As an example, the pattern lpeg.S("+-*/") matches any arithmetic operator.

Note that, if s is a character (that is, a string of length 1), then lpeg.P(s) is equivalent to lpeg.S(s) which is equivalent to lpeg.R(s..s). Note also that both lpeg.S("") and lpeg.R() are patterns that always fail.

```

5. lpeg.V (v)

```
This operation creates a non-terminal (a variable) for a grammar. The created non-terminal refers to the rule indexed by v in the enclosing grammar.

```


6. lpeg.locale ([table])

```
Returns a table with patterns for matching some character classes according to the current locale. The table has fields named alnum, alpha, cntrl, digit, graph, lower, print, punct, space, upper, and xdigit, each one containing a correspondent pattern. Each pattern matches any single character that belongs to its class.

If called with an argument table, then it creates those fields inside the given table and returns that table.

```


7. `#patt`

```


```


8. -patt

9. patt1 + patt2

10. patt1 - patt2

11. patt1 * patt2

12. patt^n

##### Grammars

##### Captures
正常的匹配返回的都是匹配成功的下一个的位置，如果要取得返回内容，需要使用capture

捕获分组的使用

```
cal name = lpeg.C(lpeg.alpha^1)
local colon = ':'
local type = lpeg.C(lpeg.digit^-1)
local value = lpeg.C(lpeg.P(1)^1)
local C = lpeg.Cg(name * colon * type * colon * value)

local str = "name:1:value"

print(C:match(str))

```

result: name    1    value

捕获的使用
- 设置捕获模式
- 进行匹配

捕获组的使用
- 设置捕获模式
- 设置捕获组模式
- 进行match匹配

Ct使用

```
local name = lpeg.Ct(lpeg.C(lpeg.alpha^1))

local str = "name:1:value"

t = name:match(str)
for k, v in pairs(t) do
    print(k, " : ", v)
end

print(name:match(str))

```
捕获组的使用，都是基于lpeg.C进行二次封装，进行进一步捕获
