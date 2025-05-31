#include "fibonacci.h"
#include <stdio.h>

VALUE rb_mFibonacci;
VALUE rb_cFibonacciExtension;

static VALUE
rb_fibonacci_class_nth_fibonacci(VALUE self, VALUE n)
{
  int nth = NUM2INT(n);
  int result = nth_fibonacci(nth);

  return INT2NUM(result);
}

int nth_fibonacci(int n) {
  if (n <= 1) {
    return n;
  }
  return nth_fibonacci(n - 1) + nth_fibonacci(n - 2);
}

void
Init_fibonacci(void)
{
  rb_mFibonacci = rb_define_module("Extension");
  rb_cFibonacciExtension = rb_define_class_under(rb_mFibonacci, "Fibonacci", rb_cObject);
  rb_define_singleton_method(rb_cFibonacciExtension, "nth_fibonacci",
                             rb_fibonacci_class_nth_fibonacci, 1);
}