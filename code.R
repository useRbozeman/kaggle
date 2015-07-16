library(data.table)
DT <- data.table(id = rep(c("id1", "id2"), c(5, 3)),
                 clust = c("A", "A", "B", "B", "N",
                           "C", "D", "G"))

cluststat <- function(X)
{
    clust <- unique(X)
    list(first = clust[1],
         second = clust[2],
         last = clust[length(clust)])
}

DT[ , cluststat(.SD$clust), by = id]


library(data.table)
library(h2o)

h2oserver <- h2o.init(nthreads = -1, max_mem_size = "3G")
h2otrain <- h2o.importFile("/home/mike/work/kaggle/taxi_time/data/train_y.csv")
# h2otrain <- as.h2o(train)

x <- c("CALL_TYPE", "TAXI_ID")

y <- "NUM_POINTS"

h2o.fit <- h2o.glm(x = x, y = y, training_frame = h2otrain, family = "poisson")

h2o.fit
