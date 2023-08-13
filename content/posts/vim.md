---
title: "Factorials & Fun with Vim"
description: "Vim trix and more"
date: 2023-08-10
tags:
  - programming
draft: false
---

I recently hit a somewhat important milestone in my life: one year as a Vim
user. Despite its steep learning curve, I used to think that mastering Vim
was mostly about habit formation. I swore by the
cheatsheets and believed I would be golden. After all, a
text editor couldn't be too terribly complex, right?

However, I soon realised how _little_ I knew about Vim and how much there
really was to know! In writing this post, I'd like to demonstrate (by
way of example) some of
the features of Vim that I found interesting; this is by no means a
comprehensive guide to Vim's capabilities (I would be lying if I said I knew half of what Vim
has to offer), but perhaps a newfound [taste of power](https://xkcd.com/378/)
for the green, fresh-off-VS Code individual looking to dabble with the dark arts.

# Computing Factorials

This post has a simple goal: computing the factorial. A classic exercise for any
new programmer -- simple to understand, but broad in terms of concepts covered.
More formally, we'll define our problem as writing a Vim routine that takes an input (ex. 5!) and spits out the factorial (120 in our example).

As a preface, I'll be referencing a variety of Vim features in this post, but I'm explicitly choosing not to explain their usage in detail. Instead, I've tried to link resources that explain syntax and functionality better than I can. This is not a tutorial as much as it is a showcase.

## State Transitions and Math

To break our problem down a bit, we need a way to multiply (and decrement) numbers in Vim, store the results somewhere, and then repeat that process N times. Sounds simple enough?

Thankfully, we don't have to implement multiplication from scratch. Vim's got us covered here with the [expression register](https://stackoverflow.com/questions/7027741/what-is-the-purpose-of-the-expression-register), noted by "=". You can access this in insert mode using `<C-r>=` and enter any expression you'd like. The expression register is clever enough to do basic math operations (addition, subtraction, multiplication, division), but not the factorial -- unfortunately
our life isn't _that_ easy.

As an example, you could enter insert mode and input `<C-r>=10*7` and the text under your cursor will be filled with 70, neat enough for simple calculations on the fly.

So we've got a way to multiply numbers, now we need to do this recursively as
well as store intermediate state somewhere. Let's tackle the state problem
first; for the sake of demonstration, we'll do the most naive thing I can think
of to store our intermediate state: write to text.

Consider a program with the following states

```
7!
6!7
5!42
4!210
...
5040
```

The contents after the ! store the intermediate state of the program, while leaving the contents before valid for recursion. We now effectively have program memory equal to the size of the text buffer we're working with!

With our states defined, we've now got to think about how exactly we transition between these states. This is where we can introduce the Vim [substitute](https://vim.fandom.com/wiki/Search_and_replace) command, which matches against patterns and replaces them according to a set of rules.

The command below matches on a number `a` followed by ! and replaces it with `(a-1)!a`. This is our base case for the recursion. We use the `.` operator to concatenate our expressions (using the expression register) together. We're also able to use `submatch(0)` which simply matches against everything captured.

```
:s/\d\+!/\=submatch(0) - 1 . "!" . submatch(0)/
```

Next, we need our "recursive case", matching on `a!b` and replacing with `a-1!b*a`. Note the introduction of capturing groups below! Previously, we only matched on one set of characters but now we have 2 distinct operations, which is also why we use indices 1 and 2 for `submatch`.

```
:s/\(\d\+\)!\(\d\+\)/\=submatch(1) - 1 . "!" . submatch(1) \* submatch(2)/
```

Fantastic! This will take 6!7 and map it to 5!42, and so on.

## Orchestration

We've got all the state transformations we need now, but we still need a way to somehow orchestrate them together in a single command. This includes finding a way to programmatically recurse on our substitution expression a variable number of times. Sounds like a lot, but Vim's again got us covered with an idiomatic tool: [the macro](https://vim.fandom.com/wiki/Macros), which is essentially a way to record sequences of edits and apply them in one shot.

Our script now looks like this (we record the macro in the `@b` register):

```
V
:s/\d\+!/\=submatch(0) - 1 . "!" . submatch(0)/
qb
V
:s/\(\d\+\)!\(\d\+\)/\=submatch(1) - 1 . "!" . submatch(1) \* submatch(2)/
q
```

Nearly done, now all we need is a way to find the number of times to execute the macro. Until now, we've been on a purist edit-only streak, but let's instead introduce some _real_ programming concepts (variables!?).

```
let i = matchstr(getline('.'), '\d\+')
execute "normal! " . i . "@b"
```

These two lines will execute our macro `i` times, where `i` is simply the value of the number we want to compute the factorial of.

Finally, this will leave us with 1!5040 (in the case of 7!). We need to perform just a bit of cleanup, since we have some extra information in the line (corresponding to our state), which we can do with the following substitution logic:

```
:s/.\*!\(\d\+\)/\1/
```

or alternatively, using [globals](https://vim.fandom.com/wiki/Power_of_g) (note the use of the Vim exclusive look-ahead `\ze`)

```
:g/.\*!\ze/normal! df!
```

And that's it! Combining all of these expressions together gives us a general factorial machine.

**Note**: I'm certainly aware of neater/shorter/better ways to do the same thing
but I wanted to go through as many different "Vim trix" as I could in a post. If
you're looking to optimise for neatness and flex your Vim muscles, you might want to check out [Vim Golf](https://vimgolf.com). I'm convinced some of the folks on there are not human.

## Means to an End

The purpose of this post is not to encourage the reader to leave
their trusted calculator behind in favour of Vim, but instead to view a
multi-stage programming problem under the lens of powerful, expressive edits.

Vim, like many other programming tools, is primarily a means to an end. It
simply happens to be powerful enough to do almost anything under the sun (if you are determined and/or
crazy enough).

What's also remarkable to me is how Vim (circa 1991) has squarely stood its ground in the everchanging landscape of software development tools. Perhaps this is a testament to the timeless quality of design
decisions made -- a seemingly rare feat in the fast-paced modern world of
software. There's a long way to go before I consider myself an expert at Vim, and I'm not
sure if there truly is an end in sight; but perhaps that's what makes it a fun
tool to use?

_P.S._: I write fondly about Vim but I should mention that I'm actually
an Emacs user. Plot twist, I know. My editor of choice is [Doom Emacs](https://github.com/doomemacs/doomemacs) which
is a smooth, Space-centric Emacs config with Vim emulation. Why fight over
Emacs vs Vim when you can have both?

## Further Reading

I realise as I write this post that a lot of what I've written about involves Vim regex.
Here's an [article](https://dev.to/iggredible/learning-vim-regex-26ep) I found
online that does a good job explaining it.

I'm often reminded of [this legendary
answer](https://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118)
which captures the essence of what I think makes Vim so enduringly good:
powerful expressivity combined with a simplistic grammar.

Lastly, here is a [well-written epitaph](https://j11g.com/2023/08/07/the-legacy-of-bram-moolenaar/) to Bram Moolenar (the creator of Vim).
