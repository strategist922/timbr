# timbr interface to randomForest

# function that describes the forest
#' @export
species.randomForest <- function(x) {
  # TODO: should also check that only two levels are present for classification
  
  # bind necessary elements into a matrix
  varInfo <- cbind(
    ncat = ifelse(x$forest$ncat == 1, 1, 0),
    num  = ifelse(sapply(x$forest$xlevels, is.numeric), 1, 0))
  
  # 1 = ordered, 2 = numeric, 0 = factor
  varTypes <- factor(apply(varInfo, 1, sum), levels = 0:2,
                     labels = c('Factor', 'Ordered', 'Numeric'))
  
  return(structure(list(
    varTypes = varTypes,
    xLevels  = x$forest$xlevels,
    nCat     = x$forest$ncat, # 1 for numeric/ordered else nlevels
    missing  = FALSE,
    class    = 'species'
  )))
}

# map random forest tree to timbr tree
#' @export
timbr.randomForest <- function(x, i, species=NULL) {
  if (is.null(species)) species <- species(x)
  
  structure(cbind(
    # different for classifaction and regression
    left       = if (x$type == 'regression') x$forest$leftDaughter[,i] else
      x$forest$treemap[,1,i],
    right      = if (x$type == 'regression') x$forest$rightDaughter[,i] else
      x$forest$treemap[,2,i],
    # random forest cannot handle missing values
    missing    = -1,
    splitVar   = x$forest$bestvar[,i],
    splitVal   = x$forest$xbestsplit[,i],
    nodeStatus = ifelse(x$forest$nodestatus[,i] == -1, -1, 0),
    nodePred   = x$forest$nodepred[,i]),
    species    = species,
    class      = 'timbr')
}