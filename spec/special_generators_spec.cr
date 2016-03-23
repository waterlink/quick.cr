require "./spec_helper"

Spec2.describe "Special generators" do
  include Quick
  include SpecHelpers

  macro describe_literal_generator(generator, value)
    describe "l : {{generator}}" do
      subject(generator) { GeneratorFor({{generator}}) }

      it "returns an Int32" do
        expect(generator.next).to be_a(typeof({{value}}))
        expect(typeof(generator.next)).to eq(typeof({{value}}))
      end

      it "always returns a specified literal value" do
        100.times do
          expect(generator.next).to eq({{value}})
        end
      end
    end
  end

  Literal.def_generator(AnswerOfTheUniverseGen, 42)
  describe_literal_generator(AnswerOfTheUniverseGen, value = 42)

  Literal.def_generator(HelloWorldGen, "hello world")
  describe_literal_generator(HelloWorldGen, value = "hello world")

  Literal.def_generator(SomeArrayGen, [1, 2, 4, 3])
  describe_literal_generator(SomeArrayGen, value = [1, 2, 4, 3])

  describe_integer_generator(
    Quick::Range(139, 792),
    count = 100000,
    median = 465,
    median_precision = 5,
    uniq_count = 600,
    log10_count = 1,
    Int32
  )

  describe_integer_generator(
    Quick::Range8(51, 125),
    count = 100000,
    median = 88,
    median_precision = 2,
    uniq_count = 70,
    log10_count = 2,
    Int8
  )

  describe_integer_generator(
    Quick::Range16(-19874, 352),
    count = 100000,
    median = -9761,
    median_precision = 100,
    uniq_count = 15000,
    log10_count = 4,
    Int16
  )

  describe_integer_generator(
    Quick::Range32(139, 792),
    count = 100000,
    median = 465,
    median_precision = 5,
    uniq_count = 600,
    log10_count = 1,
    Int32
  )

  describe_integer_generator(
    Quick::Range64(139, 792),
    count = 100000,
    median = 465,
    median_precision = 5,
    uniq_count = 600,
    log10_count = 1,
    Int64
  )

  describe_integer_generator(
    Quick::Range64(-3242342, 3242342),
    count = 100000,
    median = 0,
    median_precision = 20000,
    uniq_count = 90000,
    log10_count = 6,
    Int64
  )

  describe_float_generator(
    32,
    count = 100000,
    median = 39.75,
    median_precision = 2,
    uniq_count = 90000,
    log10_count = 1,
    FloatRange32(37, 42)
  )

  describe_float_generator(
    64,
    count = 100000,
    median = 176,
    median_precision = 5,
    uniq_count = 90000,
    log10_count = 1,
    FloatRange64(-77, 429)
  )

  describe_float_generator(
    64,
    count = 100000,
    median = 176,
    median_precision = 5,
    uniq_count = 90000,
    log10_count = 1,
    FloatRange(-77, 429)
  )
end