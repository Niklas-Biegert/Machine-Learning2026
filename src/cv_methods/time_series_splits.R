rolling_origin_splits <- function(n, initial, assess, skip = 0) {
  stops <- seq(initial, n - assess, by = assess + skip)

  lapply(stops, function(stop) {
    list(
      analysis = seq_len(stop),
      assessment = seq.int(stop + 1, stop + assess)
    )
  })
}

blocked_splits <- function(n, block_size) {
  starts <- seq(1, n, by = block_size)

  lapply(starts, function(start) {
    assessment <- seq.int(start, min(start + block_size - 1, n))
    analysis <- setdiff(seq_len(n), assessment)

    list(analysis = analysis, assessment = assessment)
  })
}

h_block_splits <- function(n, block_size, h = 1) {
  starts <- seq(1, n, by = block_size)

  lapply(starts, function(start) {
    assessment <- seq.int(start, min(start + block_size - 1, n))
    gap <- seq.int(max(1, start - h), min(n, max(assessment) + h))
    analysis <- setdiff(seq_len(n), union(assessment, gap))

    list(analysis = analysis, assessment = assessment)
  })
}
