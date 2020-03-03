package ch5

import (
	"github.com/azxj/matlab-deep-learning/Deep-Learning-for-Beginners-master/Go/utils"
	"gonum.org/v1/gonum/mat"
)

func DeepDropout(
	wss1 *mat.Dense, // 20 x 25 matrix
	wss2 *mat.Dense, // 20 x 20 matrix
	wss3 *mat.Dense, // 20 x 20 matrix
	wss4 *mat.Dense, // 5 x 20 matrix
	xss *mat.Dense, // 5 x 25 matrix
	dss *mat.Dense, // 5 x 5 matrix
) {
	alpha := 0.01 // scalar

	n := 5 // scalar
	for k := 0; k < n; k++ {
		xs := xss.RowView(k) // 25-elem vector
		ds := dss.RowView(k) // 5-elem vector

		// forward propagation
		vs1 := mat.NewVecDense(20, nil) // 20-elem vector
		vs1.MulVec(wss1, xs)
		ys1 := mat.NewVecDense(20, nil) // 20-elem vector
		utils.SigmoidVector(ys1, vs1)
		utils.Dropout(ys1, 0.2)

		vs2 := mat.NewVecDense(20, nil) // 20-elem vector
		vs2.MulVec(wss2, ys1)
		ys2 := mat.NewVecDense(20, nil) // 20-elem vector
		utils.SigmoidVector(ys2, vs2)
		utils.Dropout(ys2, 0.2)

		vs3 := mat.NewVecDense(20, nil) // 20-elem vector
		vs3.MulVec(wss3, ys2)
		ys3 := mat.NewVecDense(20, nil) // 20-elem vector
		utils.SigmoidVector(ys3, vs3)
		utils.Dropout(ys3, 0.2)

		vs4 := mat.NewVecDense(5, nil) // 5-elem vector
		vs4.MulVec(wss4, ys3)
		ys4 := mat.NewVecDense(5, nil) // 5-elem vector
		utils.Softmax(ys4, vs4)

		// backward propagation
		es4 := mat.NewVecDense(5, nil) // 5-elem vector
		es4.SubVec(ds, ys4)
		deltas4 := mat.VecDenseCopyOf(es4) // 5-elem vector
		dWs4 := mat.NewDense(5, 20, nil) // 5 x 20 matrix
		dWs4.Apply(func(i, j int, v float64) float64 {
			return alpha * deltas4.AtVec(i) * ys3.AtVec(j)
		}, dWs4)
		wss4.Add(wss4, dWs4)

		es3 := mat.NewVecDense(20, nil) // 20-elem vector
		es3.MulVec(wss4.T(), deltas4)
		deltas3 := mat.NewVecDense(20, nil) // 20-elem vector
		for i := 0; i < 20; i++ {
			deltas3.SetVec(i, ys3.AtVec(i) * (1 - ys3.AtVec(i)) * es3.AtVec(i))
		}
		dWs3 := mat.NewDense(20, 20, nil) // 20 x 20 matrix
		dWs3.Apply(func(i, j int, v float64) float64 {
			return alpha * deltas3.AtVec(i) * ys2.AtVec(j)
		}, dWs3)
		wss3.Add(wss3, dWs3)

		es2 := mat.NewVecDense(20, nil) // 20-elem vector
		es2.MulVec(wss3.T(), deltas3)
		deltas2 := mat.NewVecDense(20, nil) // 20-elem vector
		for i := 0; i < 20; i++ {
			deltas2.SetVec(i, ys2.AtVec(i) * (1 - ys2.AtVec(i)) * es2.AtVec(i))
		}
		dWs2 := mat.NewDense(20, 20, nil) // 20 x 20 matrix
		dWs2.Apply(func(i, j int, v float64) float64 {
			return alpha * deltas2.AtVec(i) * ys1.AtVec(j)
		}, dWs3)
		wss2.Add(wss2, dWs2)

		es1 := mat.NewVecDense(20, nil) // 20-elem vector
		es1.MulVec(wss2.T(), deltas2)
		deltas1 := mat.NewVecDense(20, nil) // 20-elem vector
		for i := 0; i < 20; i++ {
			deltas1.SetVec(i, ys1.AtVec(i) * (1 - ys1.AtVec(i)) * es1.AtVec(i))
		}
		dWs1 := mat.NewDense(20, 25, nil) // 20 x 25 matrix
		dWs1.Apply(func(i, j int, v float64) float64 {
			return alpha * deltas1.AtVec(i) * xs.AtVec(j)
		}, dWs1)
		wss1.Add(wss1, dWs1)
	}
}