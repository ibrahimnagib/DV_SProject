require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)

shinyServer(function(input, output) {
  
    # Start your code here.
    
    # The following is equivalent to KPI Story 2 Sheet 2 and Parameters Story 3 in "Crosstabs, KPIs, Barchart.twb"
    
    Rated_Horsepower_value = reactive({input$KPI1})
    rv <- reactiveValues(alpha = 0.50)
    Engine_Efficiency=reactive({input$Efficient})
    observeEvent(input$light, { rv$alpha <- 0.50 })
    observeEvent(input$dark, { rv$alpha <- 0.75 })
    
    df1 <- eventReactive(input$clicks1, { data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select Rated_Horsepower,Co2_G_MI_,Vehicle_Type from CARS where CO2_G_MI_ is not null and RATED_HORSEPOWER <"p1" ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_in2422', PASS='orcl_in2422', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=Rated_Horsepower_value()), verbose = TRUE)))
    })
    
output$distPlot1 <- renderPlot({ 
    plot<- ggplot() +
    coord_cartesian() + 
    scale_x_continuous() +
    scale_y_continuous() +
    labs(title=isolate(input$title)) +
    labs(x="RATED HORSEPOWER", y="CO2 G MI", color="VEHICLE TYPE") +
    layer(data=df1() , 
        mapping=aes(x=as.numeric(RATED_HORSEPOWER), y=as.numeric(CO2_G_MI_), color = as.character(VEHICLE_TYPE     )), 
         stat="identity",
        stat_params=list(), 
        geom="point",
        geom_params=list(), 
        position=position_jitter(width=0.0, height=0)
     ) 

    plot
  }) 

df2 <- eventReactive(input$clicks2, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="Select VEHICLE_MANUFACTURER_NAME,VEHICLE_TYPE, round(sum(ENGINE_EFFICIENCY)) as SUM_ENGINE_EFFICIENCY, CASE 
When ENGINE_EFFICIENCY <= "p2" THEN \\\'LOW\\\'
                                                 ELSE \\\'HIGH\\\'
                                                 END
                                                 CALCULATED_EFFICIENCY
                                                 FROM(select VEHICLE_MANUFACTURER_NAME,VEHICLE_TYPE, sum(RATED_HORSEPOWER)/sum(TEST_VEH_DISPLACEMENT_L_) as ENGINE_EFFICIENCY
                                                 from CARS 
                                                 where CO2_G_MI_ is not null 
                                                 GROUP BY VEHICLE_MANUFACTURER_NAME,VEHICLE_TYPE)
                                                 GROUP BY VEHICLE_MANUFACTURER_NAME,VEHICLE_TYPE,ENGINE_EFFICIENCY
                                                 Order by VEHICLE_MANUFACTURER_NAME ;"')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_in2422', PASS='orcl_in2422', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p2=Engine_Efficiency()), verbose = TRUE)))
 })
  
output$distPlot2 <- renderPlot({ 
  plot2 <- ggplot() + 
    coord_cartesian() + 
    scale_x_discrete() +
    scale_y_discrete() +
    labs(title=isolate(input$title2)) +
    labs(x=paste("VEHICLE_TYPE"), y=paste("VEHICLE_MANUFACTURER_NAME")) +
    layer(data=df2(), 
          mapping=aes(x=VEHICLE_TYPE, y=VEHICLE_MANUFACTURER_NAME, label=SUM_ENGINE_EFFICIENCY), 
          stat="identity", 
          stat_params=list(), 
          geom="text", 
          position=position_identity()
    ) +
    layer(data=df2(), 
          mapping=aes(x=VEHICLE_TYPE, y=VEHICLE_MANUFACTURER_NAME, fill=CALCULATED_EFFICIENCY), 
          stat="identity", 
          stat_params=list(), 
          geom="tile",
          geom_params=list(alpha=rv$alpha), 
          position=position_identity()
    )

 plot2
}) 

# the static car dataframe
car <- data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select * from CARS"')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_in2422', PASS='orcl_in2422', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON' ), verbose = TRUE)));

car2 <- car %>% group_by(VEHICLE_MANUFACTURER_NAME) %>% summarize(final = mean(sum(RATED_HORSEPOWER))) 

df3 <- eventReactive(input$clicks3, { car <- data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query="select * from CARS"')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_in2422', PASS='orcl_in2422', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON' ), verbose = TRUE))); 
})
df4 <- eventReactive(input$clicks3, {car3 <- car2 %>% summarize(final = mean(final)) 
}) 

output$distPlot3 <- renderPlot({ 
  plot3 <- ggplot() +
  coord_cartesian() + 
  scale_x_discrete() +
  scale_y_continuous() +
  labs(title="Horsepower by Manufactuer") +
  labs(x="Vehicle Manufacturer Name", y="Rated Horsepower") +
  theme(axis.text.x = element_text(angle=90,hjust=1)) +
  #  geom_text(data=car, label=(RATED_HORSEPOWER), angle=90) + # Still can't get the labels right
  layer(data=df3() , 
        mapping=aes(x=as.character(VEHICLE_MANUFACTURER_NAME), y=as.numeric(RATED_HORSEPOWER)), # Find out how to aggregate the horsepower by manufacturer name into averages
        stat="identity", 
        stat_params=list(), 
        geom="bar",
        geom_params=list(colour="blue")
  ) +
  layer(data=df4(), 
        mapping=aes(yintercept = final, label="Average"), 
        geom="hline",
        geom_params=list(colour="red")
  ) +
  layer(data=df3(), 
        mapping=aes(x=as.character(VEHICLE_MANUFACTURER_NAME), y=as.numeric(RATED_HORSEPOWER), label=mean(RATED_HORSEPOWER)), 
        stat="identity", 
        stat_params=list(), 
        geom="text",
        geom_params=list(colour="black", hjust=0), 
        position=position_identity()
  )
  
  plot3
}) 
})