library(shiny)
library(rCharts)

shinyUI(fixedPage(
        titlePanel("Literacy and life expectancy: are they related?"),
        sidebarLayout(
                mainPanel(
                        p("Hi graders! Sorry to bother you, but... Please note that I made a mistake while 
                           posting the link to my presentation. The link on Coursera will take you to 
                           https://rpubs.com/Pixelkracht/60090 but it should be:", 
                          a("http://rpubs.com/Pixelkracht/60090"),
                          em("without the 's' after https, that is!"),
                          style="background: #ffaaaa; padding: 2px;"),
                        tabsetPanel(type = "tabs", 
                                    tabPanel("Literacy and life expectancy", 
                                             showOutput("scat", "polycharts"),
                                             textOutput("cor")),                                 
                                    tabPanel("Data table", dataTableOutput("table"))                                     
                        )
                ),
                sidebarPanel(
                        p("This app explores the literacy rate and the average life expectancy in various parts of the world."),
                        p("Use the check boxes below to select a part of the world you are interested in, and hover the points on the plot to view more information about them."),
                        checkboxGroupInput("cgi", "", c("Africa", "Americas", "Eastern Mediterranean",
                                                        "Europe", "South-East Asia", "Western Pacific")),
                        h2("The data"),
                        p("The data on literacy was collected by the UN and can be found here: "),
                        a("http://data.un.org/Data.aspx?q=literacy&d=MDG&f=seriesRowID%3a656", href="http://data.un.org/Data.aspx?q=literacy&d=MDG&f=seriesRowID%3a656"),
                        br(),
                        p("The data on life expectancy was collected by the World Health Organization and can be found here: "),
                        a("http://apps.who.int/gho/data/node.main.688?lang=en", href="http://apps.who.int/gho/data/node.main.688?lang=en")
                )
        )
))
