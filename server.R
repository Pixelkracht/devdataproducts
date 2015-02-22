library(shiny)
library(rCharts)

litt <- read.table("UNdata_Export_20150208_132041718.csv", header=TRUE,
                   sep=",", stringsAsFactors=FALSE, quote="\"", fill=TRUE)
life <- read.table("lifeexpectancy.csv", header=TRUE, sep=",", stringsAsFactors=FALSE, 
                   quote="\"", fill=TRUE)
options(stringsAsFactors=FALSE)
liflit <- data.frame()

#First, some data cleaning and glueing
#life <- life[- grep("taiwan|macao|hong kong", life$COUNTRY..DISPLAY., ignore.case=TRUE),]
#Some obnoxious cases
litt[grep("bolivia", litt$Country.or.Area, ignore.case=TRUE), "Country.or.Area"]  <- "Bolivia"
litt[grep("cape verde", litt$Country.or.Area, ignore.case=TRUE), "Country.or.Area"]  <- "Cabo Verde"
litt[grep("ivoire", litt$Country.or.Area, ignore.case=TRUE), "Country.or.Area"]  <- "Ivory Coast"; 
life[grep("ivoire", life$COUNTRY..DISPLAY., ignore.case=TRUE), "Country.territory"]  <- "Ivory Coast"
litt[grep("iran", litt$Country.or.Area, ignore.case=TRUE), "Country.or.Area"]  <- "Iran" #Iran (Islamic Republic of)
litt[grep("venezuela", litt$Country.or.Area, ignore.case=TRUE), "Country.or.Area"]  <- "Venezuela" #Venezuela (Bolivarian Republic of)

life <- life[life$SEX..CODE.=="BTSX" & 
                     life$GHO..CODE.=="WHOSIS_000001" & 
                     life$YEAR..CODE. > 2006,]

for(n in 1:nrow(litt)) {
        elem <- litt[n,]
        #Does country name exist in the other data set?
        lf <- life[grep(elem["Country.or.Area"], life$COUNTRY..DISPLAY., ignore.case=TRUE),]
        if(nrow(lf) > 1) {
                #Do a more exact search
                lf <- life[grep(paste0("^", elem["Country.or.Area"], "$"), life$COUNTRY..DISPLAY., ignore.case=TRUE),]
        }
        if(nrow(lf) == 1) {
                #Find the life expectancy
                le <- lf$Numeric
                new.row <- c(elem$Country.or.Area, lf$REGION..DISPLAY., elem$Value, le)
                liflit <- rbind(liflit, new.row)
        }
}
names(liflit) <- c("Country", "Region", "Literacy", "Lexpectancy")
liflit <- liflit[complete.cases(liflit),]
liflit$Literacy <- as.integer(liflit$Literacy)
liflit$Lexpectancy <- as.integer(liflit$Lexpectancy)
#Check if we have everything
#litt[! litt$Country.or.Area %in% liflit$Country, "Country.or.Area"]

shinyServer(function(input, output) {
        sub <- reactive({
                regions <- input$cgi
                if(length(regions) > 0) {
                        liflit <- liflit[liflit$Region %in% regions, ]
                }
                liflit
                })
        output$scat <- renderChart({mytooltip <- "#! function(item) { return item.Country + ' - litt: ' + item.Literacy + ', exp: '+ item.Lexpectancy} !#"
                                    p <- rPlot(Literacy~Lexpectancy, data=sub(), type="point",
                                               color="Region", tooltip=mytooltip)
                                    p$addParams(width=800, height=400, dom="scat")
                                    p$guides(y=list(min=0, max=105, title="% of literate adults (2007-2011)"), 
                                             x=list(min=40, max=85, title="Life expectancy at birth (2012)"))
                                    return(p)})
        output$cor <- renderText(paste("Correlation:", cor(sub()$Literacy, sub()$Lexpectancy)))
        output$table <- renderDataTable(sub(), options=list(paging=FALSE))
})
