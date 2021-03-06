---
title: Predictive analytics and kaggle
author: Bozeman R useR Group
theme: miggy
---


[www.kaggle.com](http://www.kaggle.com)
=======================================

Taxi Competition
================

Steps of predictive analytics
=============================


Step 1: Data processing
=======================

---

>- Data munging/cleaning
>- 80/20 rule for data science ( [link](http://blog.revolutionanalytics.com/2014/08/data-cleaning-is-a-critical-part-of-the-data-science-process.html) )
>- For kaggle competitions data comes well organized ( [csv](./trainhead.csv.txt) )
>- Create response variable

---

### Equipment ###

- Ram: 32Gb
- SSD
- Core i7 8 virtual cores 4.4Ghz
- Atlas for BLAS and LAPACK

---

```R
train <- read.csv("train.csv")
```

. . .

121 seconds

. . .


1.8 Gb; 1.7 million rows

. . .

```R
library(readr)
train <- read_csv("train.csv")
```
25 seconds

. . .

```R
library(data.table)
train <- fread("train.csv")
```
35 seconds

---

>- Get total number of gps fixes => trip time
>- Split polyline out of the rest of the training variables
>- Save polyline and rest of training set separately


Step 2: Feature engineering
===========================

---

Create variables to go into model.

>- Transformations (log, square, inverse, standardization, discretization)
>- Interactions
>- More complicated...

---

```R
# train$new_col <- train$old_col1 / train$old_col2

train <- as.data.table(train)
train[ , new_col := old_col1 / old_col1 ]
```

. . .

```R
train[ , c("new_col1", "new_col2") :=
                         list(old_col1^2, sin(old_col2)) ]
```

. . .

```R
thedate <- as.POSIXct(as.numeric(train$TIMESTAMP),
                origin="1970-01-01", tz = "GMT")

train$DAY <- format(thedate, "%a")
train$MONTH <- format(thedate, "%b")
train$TIME <- as.numeric(format(thedate, "%H")) +
    as.numeric(format(thedate, "%M")) / 60
```

Step 3: Data augmentation
=========================

---

>- Create even more data out of the data we have
>- Easy example: image analysis
>- rotate
>- blur
>- instagram

---

>- Test data is incomplete trips
>- Training data is complete trips
>- Sample from training data a portion of the whole trip

---

```python
with open("./train_polyline.csv") as read_file,
    open("./train_aug_polyline_raw.csv", 'w') as write_file

    for line in read_file:
        n_gps = line.count('],[') + 1
        num_samples = int(math.ceil(math.log(n_gps / 5 + 1) + 1))

        for sample in range(0, num_samples):
            if n_gps == 1:
                num_gps_samp = 1
            else:
                num_gps_samp = int(math.ceil(random.uniform(1, n_gps - 1)))
            new_poly = line.split('],[')[0:num_gps_samp]
            write_file.write("\"" + "\",\"".join(new_poly) + "\"\n")
```

Step 4: Feature engineering (again)
===================================

---

>- Get information out of polyline.
>- Define clusters based on all recorded points.
>- Take augmented partial trips and cluster stats
>- Starting cluster, second cluster, most recent cluster

---

```
id1, [1, 2], [3, 4], [5, 6], ...
id2, [7, 8], [9, 10], ...
```

. . .

```csv
id1, 1, 2,
id1, 3, 4,
id1, 5, 6,
...
id2, 7, 8,
id2, 9, 10,
...
```

---

```csv
id, clust
id1, A
id1, A
id1, B
id1, B
...
id1, N
id2, C
id2, D
...
id2, G
```

. . .

```csv
id, first, second, last
id1,    A,      B,    N
id2,    C,      D,    G
...
```

---

```R
cluststat <- function(X)
{
    clust <- unique(X)
    list(first = clust[1],
         second = clust[2],
         last = clust[length(clust)])
}
```

. . .

```R
cluster_data[ , cluststat(.SD$clust), by = id]
```

Step 5: Model
=============

---

>- **DEEP LEARNING**
>- random forest
>- k-means
>- GLM!!

---

### [h2o](http://oxdata.com) ###

```R
library(h2o)

# use all threads: nthreads = -1
h2oserver <- h2o.init(nthreads = -1)
```

[localhost:54321](http://localhost:54321)

---

>- Model: Poisson
>- Response: number of gps check-ins remaining

---

```R
h2otrain <- h2o.importFile("train.csv")
# h2otrain <- as.h2o(train)

x <- c("CALL_TYPE", "TAXI_ID", "MONTH", "DAY", "TIME", "FIRST",
       "SECOND", "LAST", "POINTS_SO_FAR")

y <- "POINTS_LEFT"

h2o.fit <- h2o.glm(x = x, y = y, training_frame = h2otrain,
                   family = "poisson")
```

Step 6: Evaluation and model averaging
======================================

---

### Cross Validation ###

>- Split training data into validation and train
>- Fit on train and predict on validation
>- Evaluate performance

---

### Model averaging ###

>- Make predictions with a bunch of different types of models
>- Evaluate the performance with cross validation
>- Take a weighted average (weighted consensus) to make final predictions

Try it!
=======

---

- www.kaggle.com (Liberty Mutual Property Inspection Prediction)
- github.com/useRbozeman

