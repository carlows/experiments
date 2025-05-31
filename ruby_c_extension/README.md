# Ruby C Extensions

The goal of this experiment is to implement a ruby C extension, it should be a ruby gem that is able to call some C code.

Here's the result on an Apple M3 Pro CPU:

```
# ruby main.rb
Time taken for C extension: 1.59851 seconds
Time taken ruby function: 38.035086 seconds
```