require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)

shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    # Start your code here.
    
    # The following is equivalent to KPI Story 2 Sheet 2 and Parameters Story 3 in "Crosstabs, KPIs, Barchart.twb"
    
    Rated_Horsepower_value = input$KPI1
    
car <- data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select Rated_Horsepower,Co2_G_MI_,Vehicle_Type from CARS where CO2_G_MI_ is not null and RATED_HORSEPOWER <"p1" ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_in2422', PASS='orcl_in2422', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=Rated_Horsepower_value), verbose = TRUE)))

plot<- ggplot() +
   coord_cartesian() + 
    scale_x_continuous() +
    scale_y_continuous() +
    labs(title="PLOT 1") +
    labs(x="RATED HORSEPOWER", y="CO2 G MI", color="VEHICLE TYPE") +
    layer(data=car , 
        mapping=aes(x=as.numeric(RATED_HORSEPOWER), y=as.numeric(CO2_G_MI_), color = as.character(VEHICLE_TYPE  )), 
         stat="identity",
        stat_params=list(), 
        geom="point",
        geom_params=list(), 
        position=position_jitter(width=0.0, height=0)
  ) 

return(plot)
  }) # output$distPlot
})
