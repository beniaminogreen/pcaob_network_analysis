jaccard_similarity <- function(a, b) {
  length(intersect(a, b)) / length(union(a, b))
}

intersection_sim <- function(a, b) {
  length(intersect(a, b))
}

# stopifnot(jaccard_similarity(1, 2) == 0)
# stopifnot(jaccard_similarity(1, 1) == 1)
# stopifnot(jaccard_similarity(c(1, 2), 1) == .5)

similarity_matrix <- function(issuers) {
  n <- length(issuers)
  mat <- matrix(0, n, n)
  for (i in seq_along(issuers)) {
    for (j in seq_along(issuers)) {
      if (i != j) {
        mat[i, j] <- jaccard_similarity(issuers[[i]], issuers[[j]])
      }
    }
  }

  return(mat)
}

get_matrixes <- function(issuers) {
  W <- similarity_matrix(issuers)
  D <- diag(rowSums(W))

  list(
    W = W,
    D = D,
    L = D - W
  )
}


propagate_labels <- function(issuers, labels) {
  j <- length(labels)
  labels <- as.numeric(labels)

  mats <- get_matrixes(issuers)

  # TODO: Ensure that the J-th principal minor is full-rank.
  # If it is not, we won't be able to take the inverse of L[1:J, 1:J]

  L_uu <- mats$L[-(1:j), -(1:j)]
  # for now, we will add an epsilon to ensure rank condition is met
  L_uu <- L_uu + diag(rep(.01, nrow(L_uu)))

  W_ul <- mats$W[-(1:j), 1:j]

  imputed_labels <- solve(L_uu) %*% (W_ul %*% labels)

  c(labels, imputed_labels)
}
