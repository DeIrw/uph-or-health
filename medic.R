library(shiny)
library(plotly)
library(shinyjs)
#UI FILE------------------
ui <- fluidPage(
  # includeCSS("styles.css"),
  headerPanel(h1("Streaming Example", align = "center")),
  br(),
  br(),
  br(),
  div(plotlyOutput("plot"), id='graph'),
  useShinyjs()
)
#//------------//

#SERVER FILE------------------
server <- function(input, output, session) {
  library(jsonlite)
  data = fromJSON("http://ihealth.sepdek.net/")
  dataHealth <- as.data.frame(data)
  
  values <- reactiveValues()
  
  values$p <- plot_ly(
    type = 'scatter',
    mode = 'lines'
  ) %>%
    
    add_trace(
      name = dataHealth$healthData.sensor[5],
      y = c(dataHealth$healthData.value[5]),
      line = list(
        color = '#266dd3',
        width = 3
      )
    ) %>%
    
    layout(
      xaxis = list(title = "Seconds Passed"),
      yaxis = list(title = "Heart Rate")
    )
  output$plot <- renderPlotly({values$p})
  
  observe({
    invalidateLater(1000, session)
    data = fromJSON("http://ihealth.sepdek.net/")
    dataHealth <- as.data.frame(data)
    
    plotlyProxy("plot", session) %>%
      plotlyProxyInvoke("extendTraces",list(y=list(list(dataHealth$healthData.value[5])
      )),list(1))
  })
  
}
shinyApp(ui, server)