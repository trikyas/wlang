# WLang

WLang is a powerful code generation and templating engine.

This is the README of wlang2, a fresh new implementation of the [wlang templating language concept](http://revision-zero.org/wlang), this one implemented on top of [temple](https://github.com/judofyr/temple) and much inspired by the excellent [mustache](http://mustache.github.com/). (For users of wlang 1.0 (formaly 0.10.2), this rewrite cleans most concepts as well as the abstract wlang semantics; it also uses a simple compiler architecture to gain huge perfomance gains in comparison to early wlang days).

**WLang2 is a work in progress so far**.

## Links

* http://github.com/blambeau/wlang
* http://blambeau.github.com/wlang
* http://rubygems.org/gems/wlang
* http://revision-zero.org/wlang

## A user-defined templating engine

WLang is a templating engine, written in ruby. In that, it is similar to ERB, Mustache or whatever:

```ruby
WLang::Html.render "Hello to ${who}!", who: "you & the world"
# => "Hello you &amp; the world!"
```

To output HTML pages, WLang does not provides you with killer features or extraordinary shortcus. It supports escaping, as shown above, but many other templating engines do. For such HTML tasks, WLang does a pretty good job but many other engines perform faster and have nicer features.

WLang is designed to help you for other uses cases, user-defined ones in particular, such as generating code or whatever. WLang helps there because you can create your own _dialect_, that is, you can define your own tags and their behavior. For instance,

```ruby
class Upcasing < WLang::Dialect

  def highlight(buf, fn)
    buf << render(evaluate(fn)).upcase
  end

  tag '$', :highlight

end
Upcasing.render("Hello ${who}!"), who: "you & the world"
# => "Hello YOU & THE WORLD !"
```

WLang already provides a few useful dialects, such as WLang::Mustang (mimicing mustache) and WLang::Html (a bit more powerful in my opinion). If they don't match your needs, it is up to you to define you own dialect for making your generation task easy. Have a look at the implementation of WLang's ones, it's pretty simple to get started!

## Abstract semantics

WLang has a powerful semantics in terms of concatenation of strings and high-order functions (i.e. functions that take other functions as parameters). Let take the following template as an example:

```
Hello ${who} !
```

The functional semantics of this template is as follows:

```clojure
(fn (concat "Hello", ($ (fn "who")), " !"))
```

That is, the compilation of this template yields a function that concatenates the
string `"Hello"` with the result of the higher-order function `($ )` and then the
string `" !"`. Providing a concrete semantics to those high-order functions yields 
so called WLang _dialects_, as we've seen before.

## Higher-order constructs

A feature that distinguishes WLang from most templating engines is the fact that higher-level constructions are permitted. In addition to tag functions that accept multiple arguments, thus multiple blocks in the source text, those blocks may be complex templates themselves.

For instance, the following behavior is perfectly implementable:

```ruby
HighLevel.render "Hello #{ ${to_iterate} }{ +{self} }{ and } !",
                 to_iterate: "collection", collection: [ "you", "wlang", "world" ]
# => "Hello YOU and WLANG and WORLD"
```

An implementation of `HighLevel` might be as follows:

```ruby
class HighLevel < WLang::Dialect

  def iterate(buf, what, main, between)
    value_of(render(what)).each_with_index |val,i|
      buf << render(main, val)
      buf << render(between, val) unless i==0
    end
  end

  def varvalue(buf, fn)
    buf << evaluate(fn).to_s
  end

  def upcase(buf, fn)
    buf << evaluate(fn).to_s.upcase
  end

  tag '#', :iterate
  tag '$', :varvalue
  tag '+', :upcase

end
```

Use at your own risk, though, as it may lead to dialects that are difficult to understand and/or use and presents serious injections risks! Otherwise, higher-order constructions provides you with very powerful tools.