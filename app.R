#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jsonlite)
library(lubridate)
library(dplyr)
library(DT)

# Preprocess data
bg_data <-read_json("./BGStatsExport.json")

# Create lookups
game_ids <- sapply(bg_data$games, function(x) x$id)
game_names <- sapply(bg_data$games, function(x) x$name)
names(game_names) <- game_ids

player_ids <- sapply(bg_data$players, function(x) x$id)
player_names <- sapply(bg_data$players, function(x) x$name)
names(player_names) <- player_ids

# Create master table
num_plays <- sum(sapply(bg_data$plays, length))
game_ <- character(num_plays)
player_ <- character(num_plays)
winner_ <- numeric(num_plays)
score_ <- numeric(num_plays)
date_ <- Date(num_plays)

counter <- 0
for(row in bg_data$plays){
    for(play in row$playerScores){
        counter <- counter + 1
        game_[counter] <- game_names[paste(row$gameRefId)]
        date_[counter] <- date(ymd_hms(row$playDate))
        player_[counter] <- player_names[paste(play$playerRefId)]
        winner_[counter] <- play$winner
        if(is.null(play$score)){
            score_[counter] <- NA
        }
        else{
            score_[counter] <- play$score
        }
    }
}

bg_play_data <- data.frame(game=game_, 
                           date=date_,
                           player=player_,
                           score=score_,
                           winner=winner_)
bg_play_data$score <- as.numeric(bg_play_data$score)

# App ==========================================================================

# Define UI for application that draws a histogram
ui <- fluidPage(theme=shinythemes::shinytheme("yeti"),
        titlePanel("Board Game Crew"),
        navbarPage("Stats",
            tabPanel("Overall",
                DTOutput("overall_tbl")),
            tabPanel("By Player",
                selectInput("player_select",
                            label="Select a Player",
                            choices=unname(player_names)[2:length(player_names)],
                            selected="Chris Lew"),
                DTOutput("player_tbl")),
            tabPanel("By Game",
                selectInput("game_select",
                            label="Select a Game",
                            choices=unname(game_names)
                            ),
                DTOutput("game_tbl"))
        )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$overall_tbl <- renderDT(bg_play_data %>% 
                        filter(player != "") %>% 
                        group_by(player) %>% 
                        summarize(win_percentage=mean(winner),
                                                games_played=n()), 
                        options = list(
                            order = list(2, 'desc'), 
                            pageLength=25)
    )
    
    output$player_tbl <- renderDT(bg_play_data %>% 
                                      filter(player==input$player_select) %>% 
                                      group_by(game) %>% 
                                      summarize(games_played=n(),
                                                win_percentage=mean(winner),
                                                average_points=mean(score, na.rm=TRUE))
    )
    
    output$game_tbl <- renderDT(bg_play_data %>% 
                                      filter(game == input$game_select) %>% 
                                      group_by(player) %>% summarize(top_score=max(score), 
                                                                     lowest_score=min(score), 
                                                                     win_percentage=mean(winner),
                                                                     times_played=n()),
                                  options = list(
                                      order = list(4, 'desc'))
    )
    
    
    
    
}
# Run the application 
shinyApp(ui = ui, server = server)
