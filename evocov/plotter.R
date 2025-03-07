library(argparser)
library(dplyr)
library(tidyverse)
library(RColorBrewer)
library(stringr)
library(png)
library(hash)
library(RGenetics)

boxtext <- function(x, y, labels = NA, col.text = NULL, col.bg = NA, 
                    border.bg = NA, adj = NULL, pos = NULL, offset = 0.5, 
                    padding = c(0.5, 0.5), cex = 1, font = graphics::par('font')){
  ## The Character expansion factro to be used:
  theCex <- graphics::par('cex')*cex
  ## Is y provided:
  if (missing(y)) y <- x
  
  ## Recycle coords if necessary:    
  if (length(x) != length(y)){
    lx <- length(x)
    ly <- length(y)
    if (lx > ly){
      y <- rep(y, ceiling(lx/ly))[1:lx]           
    } else {
      x <- rep(x, ceiling(ly/lx))[1:ly]
    }       
  }
  
  ## Width and height of text
  textHeight <- graphics::strheight(labels, cex = theCex, font = font)
  textWidth <- graphics::strwidth(labels, cex = theCex, font = font)
  
  ## Width of one character:
  charWidth <- graphics::strwidth("e", cex = theCex, font = font)
  
  ## Is 'adj' of length 1 or 2?
  if (!is.null(adj)){
    if (length(adj == 1)){
      adj <- c(adj[1], 0.5)            
    }        
  } else {
    adj <- c(0.5, 0.5)
  }
  
  ## Is 'pos' specified?
  if (!is.null(pos)){
    if (pos == 1){
      adj <- c(0.5, 1)
      offsetVec <- c(0, -offset*charWidth)
    } else if (pos == 2){
      adj <- c(1, 0.5)
      offsetVec <- c(-offset*charWidth, 0)
    } else if (pos == 3){
      adj <- c(0.5, 0)
      offsetVec <- c(0, offset*charWidth)
    } else if (pos == 4){
      adj <- c(0, 0.5)
      offsetVec <- c(offset*charWidth, 0)
    } else {
      stop('Invalid argument pos')
    }       
  } else {
    offsetVec <- c(0, 0)
  }
  
  ## Padding for boxes:
  if (length(padding) == 1){
    padding <- c(padding[1], padding[1])
  }
  
  ## Midpoints for text:
  xMid <- x + (-adj[1] + 1/2)*textWidth + offsetVec[1]
  yMid <- y + (-adj[2] + 1/2)*textHeight + offsetVec[2]
  
  ## Draw rectangles:
  rectWidth <- textWidth + 2*padding[1]*charWidth
  rectHeight <- textHeight + 2*padding[2]*charWidth    
  graphics::rect(xleft = xMid - rectWidth/2, 
                 ybottom = yMid - rectHeight/2, 
                 xright = xMid + rectWidth/2, 
                 ytop = yMid + rectHeight/2,
                 col = col.bg, border = border.bg)
  
  ## Place the text:
  graphics::text(xMid, yMid, labels, col = col.text, cex = theCex, font = font, 
                 adj = c(0.5, 0.5))    
  
  ## Return value:
  if (length(xMid) == 1){
    invisible(c(xMid - rectWidth/2, xMid + rectWidth/2, yMid - rectHeight/2,
                yMid + rectHeight/2))
  } else {
    invisible(cbind(xMid - rectWidth/2, xMid + rectWidth/2, yMid - rectHeight/2,
                    yMid + rectHeight/2))
  }    
}

n <- 22
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
AAcolors <- sample(col_vector, 22, replace = F)
NTcolors <- c("red", "yellow", "blue", "green", "pink", "purple")
initialisespikeNT <- function(ylabel, type) {
  if (type == 1) {
    ylimit = 1.1
    limit = 1
    addition2 <- 0.05
  }
  plot(c(1, 3822), c(0, 0), ylim = c(0, ylimit), ylab = ylabel, 
       pch = ".", xlab = "genomic locus", xaxs="i", yaxs="i")
  rect(36, 0, 912, limit, 
       col = adjustcolor("red", alpha.f = 0.2), border = NA)
  rect(957, 0, 1623, limit, 
       col = adjustcolor("green", alpha.f = 0.2), border = NA)
  rect(1624, 0, 3624, limit, 
       col = adjustcolor("blue", alpha.f = 0.2), border = NA)
  lines(c(36, 1623), c(limit, limit), lwd = 5, col = "navy")
  lines(c(1624, 3624), c(limit, limit), lwd = 5, col = "red")
  text(200, (limit+addition2), "S1 Subunit")
  text(1750, (limit+addition2), "S2 Subunit")
}
initialiseRBDNT <- function(ylabel) {
  plot(c(1, 1273), c(0, 0), xlim = c(957,1623),ylim = c(0, 1), 
       ylab = ylabel, pch = ".", xlab = "genomic locus", xaxs="i", yaxs="i")
  rect(957, 0, 1623, 1, 
       col = adjustcolor("green", alpha.f = 0.1), border = NA)
  text(1100, (0.9), "Receptor Binding Domain", cex = 1.5, col = "navy")
}
initialisespikeAA <- function(ylabel, type) {
  if (type == 1) {
    ylimit = 1.1
    limit = 1
    addition2 <- 0.05
  }
  if (type == 2) {
    ylimit = 1.2
    limit = 1
    addition2 <- 0.4
  }
  plot(c(1, 1273), c(0, 0), ylim = c(0, (ylimit)), ylab = ylabel, pch = ".", xlab = "locus (by codon)", xaxs="i", yaxs="i")
  rect(13, 0, 304, limit, 
       col = adjustcolor("red", alpha.f = 0.2), border = NA)
  rect(319, 0, 541, limit, 
       col = adjustcolor("green", alpha.f = 0.2), border = NA)
  rect(543, 0, 1208, limit, 
       col = adjustcolor("blue", alpha.f = 0.2), border = NA)
  lines(c(12, 541), c(limit, limit), lwd = 5, col = "navy")
  lines(c(543, 1208), c(limit, limit), lwd = 5, col = "red")
  text(70, (limit+addition2), "S1 Subunit")
  text(600, (limit+addition2), "S2 Subunit")
}
initialiseRBDAA <- function(ylabel, ylimit, main = "") {
  plot(c(1, 1273), c(0, 0), xlim = c(319,541),ylim = c(0, ylimit), main = main,
         ylab = ylabel, pch = ".", xlab = "locus (by codon)", xaxs="i", yaxs="i")
  rect(319, 0, 541, ylimit, 
       col = adjustcolor("green", alpha.f = 0.2), border = NA)
}
stackedbarAA <- function(MutationTable, reference, counts) {
  AAs <- c("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P",
           "S", "T", "W", "Y", "V", "X", "*", "_")
  spikeseq <- paste0(suppressWarnings(readLines(reference)), collapse = "")
  spikeseq <- unlist(str_split(spikeseq, ""))
  spikeseq <- match(spikeseq, AAs)
  for (pos in 300:600) {
    x <- pos
    y1 <- 0
    for (AA in 1:20) {
      color <- AAcolors[AA]
      y2 <- y1 + MutationTable[pos, AA]
      lines(c(x,x), c(y1, y2), col = color, lwd = 3, lend = 1)
      y1 <- y2
    }
    if (counts[pos] > 0){
      text(x, (y1+0.01), AAs[spikeseq[x]], cex = 0.4)
    }
  }
  legend("top", inset = c(0, -0.2),legend=AAs[1:20], pch = 15, col = AAcolors[1:20],
         xpd = TRUE, horiz = T)
  

}
stackedbarAA2 <- function(MutationTable, reference, counts) {
  AAs <- c("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P",
           "S", "T", "W", "Y", "V", "X", "*", "_")
  spikeseq <- paste0(suppressWarnings(readLines(reference)), collapse = "")
  spikeseq <- unlist(str_split(spikeseq, ""))
  spikeseq <- match(spikeseq, AAs)
  for (pos in 300:600) {
    x <- pos
    y1 <- 0
    for (AA in 1:20) {
      color <- AAcolors[AA]
      y2 <- y1 + MutationTable[pos, AA]
      lines(c(x,x), c(y1, y2), col = color, lwd = 3, lend = 1)
      y1 <- y2
    }
    if (counts[pos] > 0){
      text(x, (y1+0.001), AAs[spikeseq[x]], cex = 0.5)
    }
  }
  
  
}
addfromfile <- function(filepath, type, dot, color) {
  table <- read.csv(filepath, header = T)
  counts <- rowSums(table)
  if (type == "l"){
    lines(1:length(counts), counts, col = color)
  }
  else if (type  == "p"){
    points(1:length(counts), counts, pch = dot, col = color)
  }
}
addfromfile2 <- function(filepath, type, dot, color) {
  table <- read.csv(filepath, header = T)
  counts <- rowSums(table)-table[,21]
  if (type == "l"){
    lines(1:length(counts), counts, col = color)
  }
  else if (type  == "p"){
    points(1:length(counts), counts, pch = dot, col = color)
  }
}
addfromfile3 <- function(filepath, type, dot, color) {
  table <- read.csv(filepath, header = T)
  counts <- table[,21]
  if (type == "l"){
    lines(1:length(counts), counts, col = color)
  }
  else if (type  == "p"){
    points(1:length(counts), counts, pch = dot, col = color)
  }
}
initialiseRBDspecial <- function(xlabels, ylimit) {
  plot(c(1, 1273), c(0, 0), xlim = c(0,length(xlabels)+1),ylim = c(0, ylimit), main = "Mutational Landscape of Suggested Epitope Sequence",
       ylab = "Frequency Mutated", pch = ".", xlab = "AA in Epitope", xaxt="n",xaxs="i", yaxs="i")
  axis(1, at=1:length(xlabels), labels=xlabels)
  rect(0, 0, length(xlabels)+1, ylimit, 
       col = adjustcolor("green", alpha.f = 0.2), border = NA)
}
epitopezoom <- function(epitopelist,reference,counts) {
  par(mar = c(7, 4, 3, 1))
  AAs <- c("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P",
           "S", "T", "W", "Y", "V", "X", "*", "_")
  spikeseq <- paste0(suppressWarnings(readLines(reference)), collapse = "")
  spikeseq <- unlist(str_split(spikeseq, ""))
  spikeseq <- match(spikeseq, AAs)
  num_AAs <- length(epitopelist)
  numericepitopes <- as.numeric(epitopelist)
  slices <- c()
  for (i in 1:(length(epitopelist)-1)){
    if (as.numeric(epitopelist[i+1])-as.numeric(epitopelist[i]) > 1){
      slices <- append(slices, i)
    }
  }
  if (length(slices)>0){
    for (s in 1:length(slices)){
      epitopelist <- c(epitopelist[1:(slices[s]+s-1)], "...", epitopelist[(slices[s]+s):length(epitopelist)])
    }
  }


  table <- counts[numericepitopes,]
  maxs <- max(rowSums(table) - table[,21])
  max <- maxs + (0.1*maxs)
  initialiseRBDspecial(epitopelist, max)
  count = 0
  for (x in 1:length(epitopelist)) {
    if (epitopelist[x]=="..."){
      next
    }
    count = count +1
    position <- as.numeric(epitopelist[x])
    y1 <- 0
    for (AA in 1:20) {
      color <- AAcolors[AA]
      y2 <- y1 + table[count, AA]
      lines(c(x,x), c(y1, y2), col = color, lwd = 8, lend = 1)
      y1 <- y2
    }
      text(x, (y1+(0.05*maxs)), AAs[spikeseq[position]], cex = 1)
  }
  legend("bottom", inset = c(0, -0.25),legend=AAs[1:20], pch = 15, col = AAcolors[1:20],
         xpd = TRUE, horiz = T)
}
stackedbarNT <- function(MutationTable, reference, counts) {
  AAs <- c("A", "C", "T", "G", "N", "_")
  spikeseq <- paste0(suppressWarnings(readLines(reference)), collapse = "")
  spikeseq <- unlist(str_split(spikeseq, ""))
  spikeseq <- match(spikeseq, AAs)
  for (pos in 900:1800) {
    x <- pos
    y1 <- 0
    for (AA in 1:4) {
      color <- NTcolors[AA]
      y2 <- y1 + MutationTable[pos, AA]
      lines(c(x,x), c(y1, y2), col = color, lwd = 3, lend = 1)
      y1 <- y2
    }
    if (counts[pos] > 0){
      text(x, (y1+0.01), AAs[spikeseq[x]], cex = 0.4)
    }
  }
  legend("top", inset = c(0, -0.2),legend=AAs[1:4], pch = 15, col = NTcolors[1:4],
         xpd = TRUE, horiz = T)
  
  
}
translate <- function(string){
  stringlist <- unlist(str_split(string, ""))
  geneticcode <- geneticCodeTable()
  AAseq <- c()
  for (i in seq(1, length(stringlist),3)){
    codon <- paste0(c(stringlist[i], stringlist[i+1], stringlist[i+2]), collapse = "")
    ind <- match(codon, geneticcode[,4])
    AA <- geneticcode[ind, 6]
    AAseq <- append(AAseq, AA)
  }
  return(AAseq)
}

args <- commandArgs(trailingOnly=TRUE)
nttable <- read.csv(args[1], header = F)
ntnons <- cbind(nttable[,1:4], nttable[,6])
ntcounts <- rowSums(nttable)
ntcountsnons <- rowSums(ntnons)
aatable <- read.csv(args[3], header = F)
aacounts <- rowSums(aatable)

pdf(file = "results.pdf", paper = "a4", width = 7, height = 10.5)
##Page 1
layout(matrix(c(1, 2, 3, 4, 5, 6, 7, 8), ncol = 1), heights = c(1,0.6,0.5,1,4,1, 4, 3))
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1,"EvoCov Epitope Selection Pipeline Results", cex = 2.5)
par(mar=c(0,0,0,0))
plot(1,1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1.1, cex = 1.5, paste0(c("Thank you for using the Evicov Evolution pipeline for SARS-CoV-2! The following \n results are based on ", 
                   args[2], " genome sequences from GISAID."), collapse = ""), font = 3)
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,0.8,"General Mutational Landscape by Nucleotide", cex = 2)
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1, "The following plot is a general mutational landscape for the SARS-CoV-2 spike protein nucleotide sequence for the duration of the pandemic 
(i.e. using all available parsed sequences from GISAID).For all sequences, at each locus, if the nucleotide differed from the reference, the 
count for that locus was increased by 1. The final counts for each locus were divided by the total number of sequences to give frequencies.")


par(mar=c(4.5, 4.5, 1, 1))
initialisespikeNT("Frequency Mutated", 1)
lines(1:length(ntcounts), ntcounts)
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1, "For the above graph, N's are included as a difference from the reference, to allow instances of amplicon dropping to be detected.
Specific suggestions of amplicon dropping in the data will be further elaborated on later in the variant-wise analysis. Below, the graph 
is recreated without counting Ns, and a zoomed in view is shown of the receptor binding domain.")

par(mar=c(4.5, 4.5, 1, 1))
initialisespikeNT("Frequency Mutated", 1)
lines(1:length(ntcountsnons), ntcountsnons)

par(mar=c(4.5, 4.5, 1, 1))
initialiseRBDNT("Frequency Mutated")
lines(1:length(ntcountsnons), ntcountsnons)


##Page 2
layout(matrix(c(1, 2, 3, 4, 5, 6, 7, 8), ncol = 1), heights = c(1,2,5,5, 2, 2))
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,0.8,"Mutant Codon Frequency at Each Locus", cex = 2)
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1, paste0(c("For each codon position in the RBD, a stacked bar is used to show the frequencies at that locus of codons that 
differ from the reference. Due to the heavily prevalent N501Y mutation (", AAcolors[19], ") the information in this plot is
difficult to view, so a zoomed in version is also provided."), collapse = ""))

par(mar=c(4.5, 4.5, 3, 1))
initialiseRBDAA("Frequency Mutated",  (max(aacounts[319:541])+0.05))
stackedbarAA(aatable, "Data/spike_AA.txt", aacounts)

par(mar=c(4.5, 4.5, 3, 1))
initialiseRBDAA("Frequency Mutated",  0.05)
stackedbarAA2(aatable, "Data/spike_AA.txt", aacounts)

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1, "This information is also available for the genomic sequence rather than codon-wise, but is too wide to fit nicely into 
this PDF. For that reason, it has been saved separately in the 'Plots' folder. The information shown in these plots will be used
later in epitope scoring during the calculation of shannon entropies for each locus, and when the suggested epitope is selected,
a zoomed in version of this plot for the epitope in question will be presented once more.")
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")

##Page 3
varfiles <- list.files("Analysis/variant")
details = file.info(list.files("Analysis/variant"))
details = details[with(details, order(as.POSIXct(ctime))), ]
varfiles = rownames(details)
variants <- c()
counts <- c()
for (var in varfiles) {
  v <- unlist(str_split(var, ".csv"))[1]
  c <- unlist (str_split(v, "_"))[2]
  v <- unlist (str_split(v, "_"))[1]
  variants <- append(variants, v)
  counts <- append(counts, c)
}
numvars <- length(variants)

layout(matrix(c(1, 2, 3, 4, 5, 6), byrow = T), heights = c(1,0.8,4.4,1.5, 4.2,2))
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,0.8,"Variant Wise Analysis", cex = 2)
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1, paste0(c("The following results are using the variants ", paste0(variants, collapse = ", "), 
                   " which 
                   may have been selected by you or chosen by default by the pipeline"), collapse = ""))

par(mar=c(4.5, 4.5, 3.5, 1))
initialisespikeAA("Frequency Mutated",  1)
Varcolors <- sample(brewer.pal(9,"Set1"), length(varfiles), replace = F)
for (x in 1:length(varfiles)) {
  addfromfile2(paste0(c("Analysis/variant/",varfiles[x]), collapse = ""), "p", 19, Varcolors[x])
}
legend("top", inset = c(0, -0.2),legend=variants, pch = 19, col = Varcolors,
       xpd = TRUE, horiz = T)

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1, "This plot can serve as a quality control check to ensure that the tabulation of mutations has been carried out correctly. 
The mutations specific to a given variant should have a frequency of close to 1.0 in the variant in which it has been 
documented by the CDC, and closer to 0 in other variants. For further clarity, the plots are separated out by variant 
below for the receptor binding domain (in the interests of space). Ns have been included to provide evidence for 
instances of amplicon dropping specific to some variants.")

primerlocations <- read.csv("Helpers/ARTICloci.csv", header = F)
leftstarts <- c()
leftends <- c()
rightstarts <- c()
rightends <- c()
for (i in 1:nrow(primerlocations)){
  type <- unlist(str_split(primerlocations[i,4], "_"))[3]
  if (type == "LEFT"){
    leftstarts <- as.numeric(append(leftstarts, primerlocations[i,2]- 21563)) 
    leftends <- as.numeric(append(leftends, primerlocations[i,3]- 21563))
  }
  if (type == "RIGHT"){
    rightstarts <- as.numeric(append(rightstarts, primerlocations[i,2]- 21563)) 
    rightends <- as.numeric(append(rightends, primerlocations[i,3]- 21563))
  }
}
leftends <-leftends/3
leftstarts <- leftstarts/3
rightstarts <- rightstarts/3
rightends <- rightends/3

par(mar=c(4.5, 4.5, 2, 1))
plot(c(0, 1273), c(0,0), ylim = c(0,1.07), pch=".", ylab = "Frequency Mutated", xlab = "Locus (by codon)")
#initialisespikeAA("Frequency Mutated",2)
count = 0
for (i in 1:108){
  if (abs(leftstarts[i] - leftstarts[i+1])<10){
    next
  }
  count = count+1
  addition1 <- (count%%2)*0.05
  rect(leftstarts[i],0, leftends[i], 1.01+addition1, col = adjustcolor("green", alpha.f = 0.7), border =FALSE)
  rect(rightstarts[i],0, rightends[i], 1.01+addition1, col = adjustcolor("red", alpha.f = 0.7), border =FALSE)
  arrows(leftends[i], 1.0+addition1, leftends[i]+50, 1.0+addition1, col = "green", length = 0.1, lwd = 2)
  arrows(rightstarts[i], 1+addition1, rightstarts[i]-50, 1+addition1, col = "red", length = 0.1, lwd = 2)
}
for (x in 1:length(varfiles)) {
  addfromfile3(paste0(c("Analysis/variant/",varfiles[x]), collapse = ""), "p", 19, Varcolors[x])
}





#Page 4
graph <- 0
while (graph != numvars) {
  layout(matrix(c(1,1, 2, 3, 4, 5, 6, 7, 8, 9), ncol = 2, byrow = T), heights = c(1,5,5,5,5))
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,0.8,"Variant Wise Analysis", cex = 2)
  while ((graph != numvars)) {
    par(mar=c(4.5, 4.5, 3, 1))
    graph <- graph + 1
    initialiseRBDAA("Frequency Mutated", 1, paste0(c(variants[graph], ", based on ", counts[graph], " sequences"), collapse = ""))
    addfromfile(paste0(c("Analysis/variant/", varfiles[graph]), collapse = ""), 
                "l", 1, "black")
  }
}

#Page 5
layout(matrix(c(1,1,2,2,3,3, 4, 5,6,6,7,7), ncol = 2, byrow = T), heights = c(1,0.5,3,6,0.5,4))
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,0.8,"Epitope Scoring", cex = 2)
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,0.8,"How Epitope Candidates were Selected", cex = 1.5, font = 3)
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1,"The candidates for epitopes were selected independently of the running of this pipeline and are stored in Data/candidates.txt. 
Each time the pipeline is run, the epitope candidates are loaded in and scored based on the data generated by the pipeline, 
and the top scoring candidates are returned and saved in Analysis/scoredepitopes.csv. The candidate epitopes were selected 
based on three factors: accessibility, distance between amino acids and location on the spike protein. Accessibility data 
was obtained from the Protein Data Bank Spike Trimer 7DK3, yielding 215 stretches of accessible residues. These stretches 
were filtered to only include those in the S1 subunit of the spike, as the S2 subunit is not displayed on the surface of the
SARS-CoV-2 particle. All permutations of 2, 3 and 4 stretches from the remaining 98 stretches tested for the average distance 
between the stretches in the combinations, and these permutations were filtered to give a list of all combinations of accessible
amino acids with an average distance of less than 20 ångströms apart (550,000 candidate epitopes in total). In doing this, patches
of exposed amino acids that are in close proximity but not necessarily near to each other on the spike protein sequence. Longer 
exposed stretches were also chopped up to allow their residues to be scored separately, in the event that a single residue on the
edge of a stretch may for whatever reason (being highly mutable for example) drag down the score for the whole sequence.", cex = 1)

spikemodel <-readPNG("Helpers/spike.png")
spikelabels <-readPNG("Helpers/spikelabels.png")
par(mar=c(0,0,3,0))
plot(1:10,ty="n", xaxt = "n", yaxt = "n", main = "3D Model of Spike Trimer from PDB")
rasterImage(spikemodel,1,1,10,10)
par(mar=c(0,0,3,0))
plot(1:10,ty="n", xaxt = "n", yaxt = "n", main = "Labelled Accessible AAs on Spike")
rasterImage(spikelabels,1,1,10,10)
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,0.8,"How Epitope Candidates are Scored", cex = 1.5, font = 3)
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1,"The scoring system for epitopes is still in development but for now the following factors contribute to a score of 100:

10 points - Distance: The average distance between amino acids in the epitope is calculated, and subtracted from and normalised by 15 (the 
threshold in epitope candidate selection).

5 points - Length: The epitope is awarded 1 point for each amino acid, capped at 5.

10 points - Amino Acid Score: Each amino acid has a predetermined score based on its binding characteristics, and the epitope is given a 
mark out of 5 based on its AA makeup.

65 points - Entropy: The average Shannon Entropy is calculated across each nucleotide in the epitope sequence, and normalised by the 
maximum value (0.7 approx).

10 points - Consistency: The sequences are divided up by variant and date, and the average variance of the Shannon Entropy per nucleotide is
calculated. Epitopes that do not see great changes in entropy across different variants and different points in time can earn up to 5 points.
     ", cex = 1)

#Page 6
ranks = c("red","blue","yellow","green","purple")
epitopes = suppressWarnings(read.csv("Analysis/scoredepitopes.csv", header = F))
#residuedistances <- read.csv("residuedistances.csv")
for (epitope in 1:5){
if (nrow(epitopes)<epitope){
  next
}
layout(matrix(c(1,2, 2, 3, 3,3,4, 5, 6, 7,8, 9,10,10,10), ncol = 3, byrow = T), heights = c(2.5,1,2,2,6))
par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
rect(0, 0, 2, 2, col = ranks[epitope])
text(1,1,as.character(epitope), cex = 7, col = "white", font = 2)

sequence <- epitopes[epitope,1]
sequencelist <- unlist(str_split(sequence, ""))
loci <- epitopes[epitope, 2]
locilist <- unlist(str_split(loci, "\\["))[2]
locilist <- unlist(str_split(locilist, "\\]"))[1]
locilist <- unlist(str_split(locilist, ","))

entropylist <- unlist(str_split(epitopes[epitope, 11],","))
for (x in 1:length(entropylist)){
  entropylist[x]<-as.character(round(as.numeric(entropylist[x]),3))
}

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", yaxt = "n", ylim = c(0,5), xlim = c(0,length(sequencelist)+1))
for (i in 1:length(sequencelist)) {
  x = i
  text(i,4, sequencelist[i], cex = 3)
  lines(c(i,i), c(2,3.5))
  boxtext(i,2.75, entropylist[i], cex = 2, col.bg = "pink")
  text(i,1.5, locilist[i], cex = 1.75)
}

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
text(1,1,paste0(c("Total Score: ", as.character(round(as.numeric(epitopes[epitope,10]),2))), collapse =""), cex = 3.5, font = 3)

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
rect(0, 0, 2, 2, col = "orange")
text(1,1.5,"Distance Score", cex = 2, col = "white")
text(1,0.6,as.character(round(as.numeric(epitopes[epitope,3]),2)+5), cex = 4, col = "white")

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
rect(0, 0, 2, 2, col = "limegreen")
text(1,1.5,"Length Score", cex = 2, col = "white")
text(1,0.6,as.character(round(as.numeric(epitopes[epitope,4]),2)), cex = 4, col = "white")

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
rect(0, 0, 2, 2, col = "slateblue")
text(1,1.5,"AA Score", cex = 2, col = "white")
text(1,0.6,as.character(round(as.numeric(epitopes[epitope,5]),2)), cex = 4, col = "white")

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
rect(0, 0, 2, 2, col = "blue4")
if (epitopes[epitope, 12]=="[]"){
  text(1,1.4,"0 residues", cex = 3, col = "white")
}
else{
  text(1,1.4,epitopes[epitope,12], cex = 4, col = "white")
}
text(1,0.5,"Flagged for deletions", cex = 2, col = "white")

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
rect(0, 0, 2, 2, col = "gold")
text(1,1.5,"Entropy Score", cex = 2, col = "white")
text(1,0.6,as.character(round(as.numeric(epitopes[epitope,7]),2)), cex = 4, col = "white")

par(mar=c(0,0,0,0))
plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
rect(0, 0, 2, 2, col = "deeppink")
text(1,1.5,"Consistency Score", cex = 2, col = "white")
text(1,0.6,as.character(round((as.numeric(epitopes[epitope,8])+as.numeric(epitopes[epitope,9])),2)), cex = 4, col = "white")

epitopezoom(locilist, "Data/spike_AA.txt", aatable)


if (file.exists(paste0(c("Analysis/Epitopes/ByCountryWP/", sequence, ".csv"), collapse= ""))){
  epitopecounts <- read.csv(paste0(c("Analysis/Epitopes/ByCountryWP/", sequence, ".csv"), collapse= ""), header = F)
  epitopeversions <- epitopecounts[,1]
  epitopecounts <- epitopecounts[,2:ncol(epitopecounts)]
  epitopecounts <- rbind.data.frame(epitopecounts, colSums(epitopecounts))
  epitopecounts <- rbind.data.frame(epitopecounts, rep(0, ncol(epitopecounts)))
  load("Helpers/countrydict.RData")
  WHOdata <- read.csv("WHOcasedata.csv", row.names = NULL)
  countries <- readLines("Helpers/countries.txt")
  for (i in 2:nrow(WHOdata)){
    breaking <- F
    WHOcountry <- WHOdata[i, 1]
    GISAIDcountry <- suppressWarnings(dictionary[[WHOcountry]])
    ColumnNo <- match(GISAIDcountry, countries)
    if (is.null(GISAIDcountry)){
      next
    }
    epitopecounts[nrow(epitopecounts), ColumnNo] <- epitopecounts[nrow(epitopecounts), ColumnNo] + WHOdata[i,5]*4
  }
  epitopecounts <- epitopecounts[unlist(epitopecounts[nrow(epitopecounts), ]) != 0]
  epitopecounts <- epitopecounts[unlist(epitopecounts[nrow(epitopecounts)-1, ]) != 0]
  epitopematrix <- matrix(0, nrow = nrow(epitopecounts)-2, ncol = ncol(epitopecounts)+1)
  for (j in 1:(ncol(epitopecounts)-1)){
    for (i in 1:(nrow(epitopecounts)-2)){
      if (epitopecounts[(nrow(epitopecounts)-1),j] != 0){
        epitopematrix[i,j] <- (epitopecounts[i,j]/epitopecounts[nrow(epitopecounts)-1,j])*epitopecounts[nrow(epitopecounts),j]
      }
      else {
        epitopematrix[i,j] <- 0
      }
    }
  }
  epitopematrix[,ncol(epitopematrix)] <- rowSums(epitopematrix)
  row.names(epitopematrix) <- epitopeversions
  epitopematrix <- epitopematrix[order(epitopematrix[,ncol(epitopematrix)], decreasing = TRUE),]
  epitopeversions <- row.names(epitopematrix)
  nonsynom = FALSE
  ind = 2
  while (nonsynom == FALSE){
    possib = epitopeversions[ind]
    translatedepitope = translate(possib)
    if (setequal(translatedepitope, sequencelist)){
      nonsynom == FALSE
      ind <- ind + 1
    }
    else {
      nonsynom = TRUE
      freqmutations <- c()
      for (m in 1:length(translatedepitope)){
        if (translatedepitope[m]!=sequencelist[m]){
          mutation <- paste0(c(sequencelist[m], ">", str_trim(locilist[m]),">",translatedepitope[m]), collapse = "")
          freqmutations <- append(freqmutations, mutation)
        }
      }
    }
  }
  frequencydeptmutations <- paste0(freqmutations, collapse = ", ")
  layout(matrix(c(1,1,2,3,4,5,4,6,4,7,4,8,4,9,4,10,4,11), ncol = 2, byrow = T), heights = c(1,0.8,4,0.8,4,0.8,4,0.8,4))
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,0.8,"Mutability Analysis/Predicted Variants", cex = 2)
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,1,"Variations of the epitope and 
their normalised global frequency over the pandemic", cex = 1.3, font = 3)
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,1,"Prediction based on comparison to neutral rates", cex = 1.3, font = 3)
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", yaxt = "n", ylim = c(0.5,length(epitopeversions)+0.5), xlim = c(0,5))
  startpoint <- ((length(sequencelist) - 7)*0.1) + 3
  for (i in 1:length(epitopeversions)) {
    y = length(epitopeversions) - i + 0.5
    text(1.5,y, epitopeversions[i], cex = 1)
    lines(c(startpoint,4.15), c(y,y))
    text(4.5,y, as.character(round((epitopematrix[i, ncol(epitopematrix)])/sum(epitopematrix[,ncol(epitopematrix)]), 3)), cex = 1)
  }
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "cadetblue")
  text(1,1.5,epitopes[epitope,13], cex = 3, col = "white")
  text(1,0.6,epitopes[epitope,14], cex = 3, col = "white")
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,1,"Prediction based on baseml estimated mutation rates", cex = 1.3, font = 3)
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "darkolivegreen4")
  text(1,1.5,epitopes[epitope,15], cex = 3, col = "white")
  text(1,0.6,epitopes[epitope,16], cex = 3, col = "white")
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,1,"Prediction based on selection coefficient", cex = 1.3, font = 3)
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "brown1")
  text(1,1.5,epitopes[epitope,17], cex = 3, col = "white")
  text(1,0.6,epitopes[epitope,18], cex = 3, col = "white")
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,1,"Prediction based on normalised global frequency", cex = 1.3, font = 3)
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "darkgoldenrod1")
  text(1,1, frequencydeptmutations, cex = 3, col = "white")
}


}

#Page 7
if (FALSE){
ranks = c("red","blue","yellow","green","purple")
epitopes = suppressWarnings(read.csv("Analysis/scoredslidingwindowepitopes.csv", header = F))
#residuedistances <- read.csv("residuedistances.csv")
for (epitope in 1:5){
  if (nrow(epitopes)<epitope){
    next
  }
  layout(matrix(c(1,2, 2, 3, 3,3,4, 5, 6, 7,8, 9,10,10,10), ncol = 3, byrow = T), heights = c(2.5,1,2,2,6))
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  rect(0, 0, 2, 2, col = ranks[epitope])
  text(1,1,as.character(epitope), cex = 7, col = "white", font = 2)
  
  sequence <- epitopes[epitope,1]
  sequencelist <- unlist(str_split(sequence, ""))
  loci <- epitopes[epitope, 2]
  locilist <- unlist(str_split(loci, "\\["))[2]
  locilist <- unlist(str_split(locilist, "\\]"))[1]
  locilist <- unlist(str_split(locilist, ","))
  
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", yaxt = "n", ylim = c(0,5), xlim = c(0,length(sequencelist)+1))
  for (i in 1:length(sequencelist)) {
    x = i
    text(i,4, sequencelist[i], cex = 3)
    text(i,1.5, locilist[i], cex = 1.75)
    lines(c(i,i), c(2,3))
  }
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n")
  text(1,1,paste0(c("Total Score: ", as.character(round(as.numeric(epitopes[epitope,10]),2))), collapse =""), cex = 3.5, font = 3)
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "orange")
  text(1,1.5,"Accessibility Score", cex = 2, col = "white")
  text(1,0.6,as.character(round(as.numeric(epitopes[epitope,3]),2)), cex = 4, col = "white")
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "limegreen")
  text(1,1.5,"Length Score", cex = 2, col = "white")
  text(1,0.6,as.character(round(as.numeric(epitopes[epitope,4]),2)), cex = 4, col = "white")
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "slateblue")
  text(1,1.5,"AA Score", cex = 2, col = "white")
  text(1,0.6,as.character(round(as.numeric(epitopes[epitope,5]),2)), cex = 4, col = "white")
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "blue4")
  text(1,1.5,"Location Score", cex = 2, col = "white")
  text(1,0.6,as.character(round(as.numeric(epitopes[epitope,6]),2)), cex = 4, col = "white")
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "gold")
  text(1,1.5,"Entropy Score", cex = 2, col = "white")
  text(1,0.6,as.character(round(as.numeric(epitopes[epitope,7]),2)), cex = 4, col = "white")
  
  par(mar=c(0,0,0,0))
  plot(1, 1, col = "white", xaxt = "n", bty = "n", yaxt = "n", ylim = c(0,2))
  rect(0, 0, 2, 2, col = "deeppink")
  text(1,1.5,"Consistency Score", cex = 2, col = "white")
  text(1,0.6,as.character(round((as.numeric(epitopes[epitope,8])+as.numeric(epitopes[epitope,9])),2)), cex = 4, col = "white")
  
  epitopezoom(locilist, "Data/spike_AA.txt", aatable)
}
}
dev.off()



pdf(file = "Plots/ntstackedbar.pdf", width = 15, height = 4)
par(mar = c(4,4,4,2))
initialiseRBDNT("Frequency Mutated")
stackedbarNT(nttable, "Data/spike_NT.txt", ntcounts)
dev.off()



