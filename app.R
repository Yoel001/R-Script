library(shiny)
library(shinythemes)
library(ggvis)

#######################################################################################################
# User Interface
#######################################################################################################
ui <- shinyUI(pageWithSidebar(
  div(),
  sidebarPanel(
    h1("GGVIS Example"),
    uiOutput("ggvis_ui"),
    uiOutput("ggvis_ui2"),
    actionButton("goButton", "Fresh Data", icon = icon("fa fa-refresh"))
  ),
  mainPanel(
    ggvisOutput("plot"),
    ggvisOutput("plot2")
  )
))

#######################################################################################################
# Server
#######################################################################################################
server <- shinyServer(function(input, output, session) {
  
  data <- reactive({ 
    # Make action button dependency
    input$goButton
    # but isolate input$sample
    isolate(data.frame("a" = rnorm(100, mean=2, sd=3), 'b'= rnorm(100, mean=7, sd=1)))
  })
  
  autoInvalidate <- reactiveTimer(1000, session)
  data2 <- reactive({ 
    autoInvalidate()
    data.frame("a" = rnorm(100, mean=2, sd=3), 'b'= rnorm(100, mean=7, sd=1))
  })
  
  data %>% ggvis(~a, ~b) %>% 
    layer_points(fill := "red") %>%
    layer_points(stroke := "black", fill := NA , size := input_slider(5, 100)) %>%
    layer_smooths()%>%
    bind_shiny("plot", "ggvis_ui")
  
  data2 %>% ggvis(~b) %>% 
    layer_densities(adjust = input_slider(.1, 2, value = 1, step = .1, label = "Bandwidth adjustment")) %>%
    bind_shiny("plot2", "ggvis_ui2")                
})

#######################################################################################################
# Compile app
#######################################################################################################    
shinyApp(ui, server)