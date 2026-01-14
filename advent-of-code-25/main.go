package main

import (
	"fmt"
	"os"
)

func assert(message string, actual any, expected any) {
	if actual != expected {
		fmt.Printf("Assertion failed: %s expected: %#v actual: %#v\n", message, expected, actual)
		os.Exit(1)
	}
	fmt.Printf("Assertion passed: %s\n", message)
}

func main() {
	Day01()
	Day02()
}
