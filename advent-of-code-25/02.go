package main

import (
	"os"
	"strconv"
	"strings"
)

type Range struct {
	start int
	end   int
}

func partOne02(input string) int {
	ranges := parse02(input)
	result := 0

	for _, numRange := range ranges {
		partialResult := 0

		for i := numRange.start; i <= numRange.end; i++ {
			num := strconv.Itoa(i)
			half := len(num) / 2
			if half == 0 {
				continue
			}

			if len(num)%half == 0 && duplicate(num[0:half], 2) == num {
				partialResult += i
			}
		}

		result += partialResult
	}

	return result
}

func partTwo02(input string) int {
	ranges := parse02(input)
	result := 0

	for _, numRange := range ranges {
		partialResult := 0

		for i := numRange.start; i <= numRange.end; i++ {
			num := strconv.Itoa(i)
			half := len(num) / 2
			if half == 0 {
				continue
			}

			for y := 1; y <= half; y++ {
				if len(num)%y == 0 && duplicate(num[0:y], len(num) / y) == num {
					partialResult += i
					break
				}
			}
		}

		result += partialResult
	}

	return result
}

func duplicate(slice string, n int) string {
	return strings.Repeat(slice, n)
}

func parse02(input string) []Range {
	cleaned := strings.TrimSpace(input)
	split := strings.Split(cleaned, ",")
	ranges := []Range{}

	for _, line := range split {
		splittedLine := strings.Split(line, "-")
		start, _ := strconv.Atoi(splittedLine[0])
		end, _ := strconv.Atoi(splittedLine[1])

		ranges = append(ranges, Range{start: start, end: end})
	}

	return ranges
}

func Day02() {
	assert("Day 2 works with simple ranges", partOne02("11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"), 1227775554)

	input, err := os.ReadFile("input02.txt")
	if err != nil {
		panic(err)
	}

	assert("Day 2 works with small range", partOne02("2-17"), 11)
	assert("Day 2 works with the real deal", partOne02(string(input)), 15873079081)
	assert("Day 2 works with the real deal part two", partTwo02(string(input)), 22617871034)
}
