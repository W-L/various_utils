#! /bin/Rscript
# xtable generator

library(data.table)
library(xtable)

args <- commandArgs(TRUE)

table.png <- function(obj, name) { 
  first <- name
  name <- paste(name,".tex",sep="")
  sink(file=name)
  cat('
\\documentclass{report}
\\usepackage[paperwidth=5.5in,paperheight=7in,noheadfoot,margin=0in]{geometry}
\\begin{document}\\pagestyle{empty}
')
  print(xtable::xtable(obj),include.rownames = FALSE)
  cat('
\\end{document}
')
  sink()
  tools::texi2dvi(file=name)
  cmd <- paste("dvipng -T tight -bg Transparent -D 200", shQuote(paste(first,".dvi",sep="")))
  invisible(system(cmd))
  cleaner <- c(".tex",".aux",".log",".dvi")
  invisible(file.remove(paste(first,cleaner,sep="")))
}


# --------------


table <- fread(args[1])
table.png(table, args[1])


