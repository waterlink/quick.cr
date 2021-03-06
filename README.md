# quick [![Build Status](https://travis-ci.org/waterlink/quick.cr.svg?branch=master)](https://travis-ci.org/waterlink/quick.cr)

QuickCheck implementation for Crystal Language.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  quick:
    github: waterlink/quick.cr
    version: ~> 1.0
```

## Usage

```crystal
require "quick"
```

### Property testing

```crystal
Quick.check("add reflexivity", [x : Int32, y : Int32]) do
  add(x, y) == add(y, x)
end
```

It raises `Quick::CheckFailedError(T)` when property does not hold for some
values. `T` is a type of tuple, containing all failed arguments.
These failed arguments are accessible on error instance as `error.failed_args`.

### Configuration

`Quick.check` accepts different keyword arguments, that can be combined:

- `Quick.check("property", [value : Int32], number_of_tests: 100)` - `number_of_tests` controls,
  how much tests are generated to verify the property. Default: `100`.

### Control over generated data

`Quick.check` determines generator for the data from the type annotation of a
block arguments. Possible options:

- A basic type with default min/max limits:
  - `x : Int32`, also, `UInt32, Int8, UInt8, Int16, UInt16, Int64 and UInt64` are supported,
  - `s : String`,
  - `f : Float64`, also, `Float32` is supported,
  - `c : Char`
  - `b : Bool`,
  - `a : Array(Int32)`, and `Array(T)` in general case, where `T` can be any of supported basic types, built-in generators and user-defined generators,
  - `p : Tuple(Int32, Float64)` (pair), `Tuple(T, U)` in general case,
  - `h : Hash(String, Float64)`, `Hash(K, V)` in general case,
- One of the range: `value : Quick::Range(13, 79)`
  - `Quick::Range` is an alias for `Quick::Range32`, which works only with `Int32`
  - `Quick::Range8` and `Quick::Range16` are available for corresponding `Int8` and `Int16` types
  - `Quick::Range64` is available, but cannot be used with ranges out of `Int32` boundaries (see: crystal-lang/crystal#2353)
  - `Quick::FloatRange` and `Quick::FloatRange64` for ranges of type `Float64`
  - `Quick::FloatRange32` for ranges of type `Float32`
- Array of specific size: `a : Quick::Array(Int32, 50)`
- Array of generated size: `a : Quick::Array(Int32, Quick::Range(0, 1000))`
- String of specific size: `s : Quick::String(15)`
- String of generated size: `s : Quick::String(Quick::Range(0, 50))`
- Numeric value for a size (same as `Int32`, but has smaller default limit 0..100): `size : Quick::Size`
- Pick one value from the list: `Quick.def_choice(ColorGen, "red", "blue", "green")` and use it as `value : ColorGen`
- Pick one generator from the list: `Quick.def_gen_choice(RandomStuffGen, Int32, HelloWorldGen, ColorGen, FloatRange(2, 4), Bool)` and use it as `value : RandomStuffGen`

### Literal generator that returns same value

First define your own literal generator class, that will always return provided value:

```crystal
# it defines special HelloWorldGen type, that can be
# used in type annotations afterwards
Quick.def_literal(HelloWorldGen, "hello world")
```

And then use it:

```crystal
Quick.check("property") do |s : HelloWorldGen|
  s == "hello world"
end
```

### Building your own generator

If you have your own custom data structure, that you want to generate data for,
you simply need to create new generator that conforms to `Quick`'s Generator(T)
protocol:

- `include Generator(T)`, where `T` is the type of generated value, and
- implement `self.next : T` method

```crystal
record User, :email, :password

# E - email size gen
# P - password size gen
class UserGen(E, P)
  include Quick
  include Generator(User)

  def self.next : User
    User.new(
      String(GeneratorFor(E).next).next + "@example.org",
      String(GeneratorFor(P).next).next
    )
  end
end
```

Then you should be able to use it as:

```crystal
Quick.check("valid user") do |user : UserGen(Quick::Size, Quick::Size)|
  user.valid?
end

# or with custom size generators
Quick.check("valid user") do |user : UserGen(Quick::Range(10, 20), Quick::Range(16, 21))|
  user.valid?
end
```

### Defining a shrinking strategy on your generators

- `include Quick::Shrinker(T)`, where T is type of shrinked values,
- and implement `def self.shrink(failed_value : T, prop : T -> Bool) : T`.

`self.shrink` should make a guess about the next shrinked value and verify,
that it still fails by calling `prop`:

```crystal
next_value = .. guess next shrinked value from `failed_value` ..
if prop.call(next_value)
  .. No, guess is incorrect, property will succeed with `next_value` ..
  .. typically rollback, and try another guess, continue the loop or use recursion ..
else
  .. Yes, guess is correct, property still fails with `next_value` ..
  .. typically, continue on improving your guess, continue the loop or use recursion ..
end
```

At any point of time, if you can't make a better guess, that still fails
`prop`, then it is time to return a last known best shrinked still failing
value.

Enough with the words, example:

```crystal
class UppercaseLetter
  include Quick::Generator(Char)
  include Quick::Shrinker(Char)

  def self.next : Char
    # .. generate next random uppercase letter ..
  end

  def self.shrink(failed_value : Char, prop : Char -> Bool) : Char
    # make a best guess (#pred returns previous character)
    guess = failed_value.pred

    # check that value is still valid
    # and check that property is still failing
    if guess >= 'A' && !prop.call(guess)
      # recur with our new improved shrinked failing value
      return shrink(guess, prop)
    end

    # otherwise return last-known best shrinked still failing value
    failed_value
  end
end
```

You may want to re-use built-in and other existing shrink strategies in your
shrink strategy, use it as:

```crystal
Quick::ShrinkerFor(S).shrink(value, prop)
```

Where `S` - built-in generator (`GeneratorFor(Array(Int32))` for example), or
any custom shrinker, that `include`-s `Shrinker(T)` and implements
`self.shrink(T, T -> Bool) : T`.

## Development

After cloning this repository, run `shards install` to install dependencies.

To run the test suite, use `crystal spec`.

## Contributing

1. Fork it ( https://github.com/waterlink/quick.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator,
  maintainer
