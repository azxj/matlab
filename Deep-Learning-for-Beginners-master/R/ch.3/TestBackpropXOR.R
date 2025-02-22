rm(list=ls())

source("./BackpropXOR.R")
source("./Sigmoid.R")

X <- matrix(c(
  0, 0, 1,
  0, 1, 1,
  1, 0, 1,
  1, 1, 1
), nrow=4, ncol=3, byrow=TRUE)

D <- c(
  0,
  1,
  1,
  0
)

W1 <- array(runif(12, min=-1, max=1), c(4, 3))
W2 <- array(runif(4, min=-1, max=1), c(1, 4))

for (epoch in 1:10000) { # train
  Ws <- BackpropXOR(W1, W2, X, D)
  W1 <- Ws$W1
  W2 <- Ws$W2
}

N <- 4 # inference
for (k in 1:N) {
  x <- X[k,]
  v1 <- W1 %*% x
  y1 <- Sigmoid(v1)
  v <- W2 %*% y1
  y <- Sigmoid(v)
  print(y)
}
