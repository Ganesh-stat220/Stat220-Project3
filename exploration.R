library(tidyverse)
library(httr)
library(magick)
api_key <- "kzTrX1AnpKXiCau4lZa36WYRR6StCcgTcwxUFO7ULzdeUXDrEcIj6qNW"

url <- "https://api.pexels.com/v1/search?query=snowy+mountains&per_page=80"

response <- httr::GET(url, 
                      add_headers(Authorization = api_key))

data <- httr::content(response, 
                      as = "parsed", 
                      type = "application/json")

photo_data <- tibble(photos = data$photos) %>%
  unnest_wider(photos) %>%
  unnest_wider(src)

# Creating a new size_category column that classifies photos as
selected_photos <- photo_data %>%
  mutate(size_category = case_when(
    width < 3000 ~ "small",
    width >= 3000 & width < 5000 ~ "medium",
    width >= 5000 ~ "large"
  )) %>%
  
  mutate(aspect_ratio = width / height) %>%
  
  mutate(colorfulness = ifelse(is.na(avg_color), 0, {
    rgb_values <- col2rgb(avg_color)
    1 - mean(rgb_values) / 255  # 0 = white, 1 = black
  })) %>%
  
  filter(size_category == "large",
         as.numeric(photographer_id) > 4000) %>%
  slice(1:20) %>%
  select(id, width, height, aspect_ratio, size_category, colorfulness,
         photographer, photographer_url, url, avg_color)

write_csv(selected_photos, "selected_photos.csv")

mean_aspect <- selected_photos$aspect_ratio %>% mean(na.rm = TRUE)

# Count number of photos in each size category (categorical variable)
size_counts <- selected_photos %>% 
  count(size_category)

# Calculate median popularity score (numeric variable)
median_color <- selected_photos$colorfulness %>% median(na.rm = TRUE)


# 3. Additional useful summaries (optional but recommended)

# Summary of photo dimensions by size category
size_dimensions <- selected_photos %>%
  group_by(size_category) %>%
  summarise(
    avg_width = mean(width),
    avg_height = mean(height),
    total_pixels = sum(width * height)  # Total pixel area across all photos
  )

print(paste("Mean aspect ratio:", round(mean_aspect, 2)))
print(paste("Median color:", round(median_color, 2)))


print(size_counts)



animation_meme1 <- image_read("https://images.pexels.com/photos/858115/pexels-photo-858115.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
animation_meme2 <- image_read("https://images.pexels.com/photos/1054218/pexels-photo-1054218.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
animation_meme3 <- image_read("https://images.pexels.com/photos/2835436/pexels-photo-2835436.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")
animation_meme4 <- image_read("https://images.pexels.com/photos/31780892/pexels-photo-31780892/free-photo-of-stunning-winter-view-of-canadian-rockies.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1")

text1 = "I really wish"
text2 = "Auckland has"
text3 = "more"
text4 = "snowy mountains"

frame1 <- animation_meme1 %>%
  image_annotate(text = text1, 
                 size = 50, 
                 font = "impact", 
                 color = "#FFF", 
                 gravity = "center", 
                 location = "+0+0") 

frame2 <- animation_meme2 %>%
  image_annotate(text = text2, 
                 size = 50, 
                 font = "impact", 
                 color = "#FFF", 
                 gravity = "center", 
                 location = "+0+0") 

frame3 <- animation_meme3 %>%
  image_annotate(text = text3, 
                 size = 50, 
                 font = "impact", 
                 color = "#FFF", 
                 gravity = "center", 
                 location = "+0+0")

frame4 <- animation_meme4 %>%
  image_annotate(text = text4, 
                 size = 50, 
                 font = "impact", 
                 color = "#FFF", 
                 gravity = "center", 
                 location = "+0+0")

animation <- c(frame1, frame2, frame3, frame4) %>%
  image_animate(fps = 2)
animation

image_write(animation, "creativity.gif")
