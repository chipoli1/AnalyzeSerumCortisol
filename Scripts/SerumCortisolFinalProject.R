## Project submitted by Charmaine Hipolito
## Serum Cortisol Parameter
## BTEC395 S2020 GX Robinson


## Set working directory to source file location


## Read in the table of fold changes
FCdata <- read.csv("../data/FCSerum.csv", row.names = 1, header = FALSE)

## Read in the table of expression data
IBS <- read.csv("../data/GXdata.csv", header = TRUE)

## Access only the columns with RNA Expression (subsetting)
names(IBS)[28:277]

## Make a list of anova(lm()) results for serum cortisol
storage <- list()

for(i in names(IBS)[28:277]){
  storage[[i]]  <- anova(lm(get(i) ~ Cortisol, IBS))
}

## Extract the serum cortisol p-values into a new list
pVals <- list()

for(i in names(storage)){
  pVals[[i]] <- -(log10(storage[[i]]$'Pr(>F)'))
}

## Convert the pValues list into a data frame. 
DFpvalues <- data.frame(matrix(unlist(pVals), nrow=length(pVals), byrow=T))

## Combine the results dataframes and write column labels: Serum cortisol 
VolcanoPlotData <- cbind(FCdata, DFpvalues)
names(VolcanoPlotData)[1] <- paste("log2(SlopeDiff)")
names(VolcanoPlotData)[2] <- paste("-log10(Pval)")

## Add a column to evaluate significance
VolcanoPlotData$Sig <- ifelse(VolcanoPlotData$`-log10(Pval)` > 1.3, "Sig", "Insig");
  
## Install necessary packages
install.packages("ggplot2")
library(ggplot2)
# library(ggrepel)

##  Output the result of the Serum Cortisol volcano plot into Fig_Output folder
png("../fig_output/SerumCortisolplot.png")
SerumCortisolplot <- ggplot(VolcanoPlotData, aes(x = `log2(SlopeDiff)`, y = `-log10(Pval)`, label=rownames(VolcanoPlotData), color=Sig)) +
  geom_point(aes(color = Sig)) +
  scale_color_manual(values = c("grey", "red")) +
  theme_bw(base_size = 12) + theme(legend.position = "bottom") +
  geom_text(aes(x = `log2(SlopeDiff)`,y = `-log10(Pval)`, fontface = 1, size=3,  label=row.names(VolcanoPlotData)))
  

print(SerumCortisolplot + ggtitle("Gene Expression vs. Serum Cortisol Level"))
dev.off()



