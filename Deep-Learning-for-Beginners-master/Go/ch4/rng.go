package ch4

import "math/rand"

func Rng(x int) {
	rand.Seed(int64(x))
}
