library(ape)
library(dendextend)
library(ggplot2)
library(ggdendro)


inp <- '/Users/lweilguny/Desktop/vetgrid/consensus_te/14_modeltree/matrix.D'

distmat <- read.delim(inp, sep=' ', row.names=1, header=T)
distmat <- as.dist(distmat, diag=TRUE, upper=TRUE)


# bionj tree
tree <- bionj(distmat)

tree$tip.label <- as.character(c("deme 1", "deme 2", "deme 3"))
#tree <- root(tree, outgroup = 'deme 1')
#cons <- c("deme 1", "deme 2", "deme 3")
#tree <- rotateConstr(tree, constraint = rev(cons))


pdf(width=4, height=4, file=paste(inp, "_tree.pdf", sep=""))
plot(tree, type="unrooted", show.node.label=T)
dev.off()
