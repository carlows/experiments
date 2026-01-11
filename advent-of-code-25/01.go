package main

import (
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Item struct {
	direction string
	distance  int
}

func parse(input string) []Item {
	lines := strings.Split(input, "\n")
	items := []Item{}
	regex := regexp.MustCompile(`(L|R)(\d+)`)
	for _, line := range lines {
		match := regex.FindStringSubmatch(line)
		if len(match) > 0 {
			distance, _ := strconv.Atoi(match[2])
			items = append(items, Item{string(match[1]), distance})
		}
	}
	return items
}

func mod(a, b int) int {
	r := a % b
	if r < 0 {
		r += b
	}
	return r
}

func partOne(input string) int {
	currentClock := 50
	result := 0
	items := parse(input)
	for _, item := range items {
		for i := 0; i < item.distance; i++ {
			if item.direction == "L" {
				currentClock--
			} else {
				currentClock++
			}
			currentClock = mod(currentClock, 100)
		}
		if currentClock == 0 {
			result++
		}
	}
	return result
}

func partTwo(input string) int {
	currentClock := 50
	result := 0
	items := parse(input)
	for _, item := range items {
		for i := 0; i < item.distance; i++ {
			if item.direction == "L" {
				currentClock--
			} else {
				currentClock++
			}
			currentClock = mod(currentClock, 100)
			if currentClock == 0 {
				result++
			}
		}
	}
	return result
}

func Day01() {
	multilineString := `L68
L30
R48
L5
R60
L55
L1
L99
R14
L82`
	assert("Day 1 sample input", partOne(multilineString), 3)

	input, err := os.ReadFile("input01.txt")
	if err != nil {
		panic(err)
	}

	assert("Day 1 part one", partOne(string(input)), 1105)
	assert("Day 1 part two", partTwo(string(input)), 6599)
}
