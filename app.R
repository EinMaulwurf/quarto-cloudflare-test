library(shiny)
library(ggplot2)

# Define your Shiny UI here
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("demand_slope", "Demand Slope", 
                  min = -4, max = -1, value = -2, step = 0.5),
      sliderInput("supply_slope", "Supply Slope", 
                  min = 1, max = 5, value = 3, step = 0.5)
    ),
    mainPanel(
      plotOutput("plot", width=500)
    )
  )
)

# Define your Shiny server logic here
server <- function(input, output, session) {
  output$plot <- renderPlot({
    # Define demand and supply functions
    demand <- function(x) 100 + input$demand_slope * x
    supply <- function(x) 50 + input$supply_slope * x
    
    quant_balance <- uniroot(function(x) demand(x) - supply(x), interval = c(0, 30))$root
    price_balance <- demand(quant_balance)
    
    # Generate data points
    x_values <- seq(0, 30, by = 1)
    demand_data <- data.frame(x = x_values, y = demand(x_values), type = "Demand")
    supply_data <- data.frame(x = x_values, y = supply(x_values), type = "Supply")
    data <- rbind(demand_data, supply_data)
    
    # Create supply-demand diagram
    ggplot(data, aes(x = x, y = y, color = type)) +
      geom_line() +
      labs(x = "Quantity",
           y = "Price",
           subtitle = paste("Gleichgewichtspreis:", round(price_balance, 2), sep = " ")) +
      coord_cartesian(xlim = c(0,30), ylim = c(50, 100))+
      theme_bw()
  }, res=140)
}

# Create and launch the Shiny app
shinyApp(ui, server)