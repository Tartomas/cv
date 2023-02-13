# This script builds both the HTML and PDF versions of your CV

# If you want to speed up rendering for googlesheets driven CVs you can cache a
# version of your data This avoids having to fetch from google sheets twice and
# will speed up rendering. It will also make things nicer if you have a
# non-public sheet and want to take care of the authentication in an interactive
# mode.
# To use, simply uncomment the following lines and run them once.
# If you need to update your data delete the "ddcv_cache.rds" file and re-run
suppressWarnings({
  library(googlesheets4)
  googledrive::drive_auth_configure(api_key = Sys.getenv("GGDRIVE_key"))
  # sheets_auth_configure(api_key = Sys.getenv("GGDRIVE_key"))
  # sheets_deauth()
})

library(tidyverse)
source("CV_printing_functions.R")
sheet <- 'https://docs.google.com/spreadsheets/d/19cvVvku2dH3nnwa3cpJlr8hMnIod7VKaC5kohYa14Q4/edit?usp=sharing'
cv_data <- create_CV_object(
  data_location = sheet,
  cache_data = FALSE
)

readr::write_rds(cv_data, 'cached_positions.rds')
cache_data <- TRUE

# # Knit the HTML version
# rmarkdown::render("cv.Rmd",
#                   params = list(pdf_mode = FALSE, cache_data = cache_data),
#                   output_file = "index.html")
# 

# Knit the PDF version to temporary html location
tmp_html_cv_loc <- fs::file_temp(ext = ".html")
rmarkdown::render("cv.Rmd",
                  params = list(pdf_mode = TRUE, cache_data = cache_data),
                  output_file = tmp_html_cv_loc)

# Convert to PDF using Pagedown
taroutput = paste0("TAR_CV_",lubridate::year(Sys.Date()),".pdf")
pagedown::chrome_print(input = tmp_html_cv_loc,
                       output = taroutput)


#### SHORT
# Knit the PDF version to temporary html location
#tmp_html_cv_loc <- fs::file_temp(ext = ".html")

rmarkdown::render("resume.Rmd",
                  params = list(pdf_mode = TRUE, cache_data = cache_data),
                  output_file = 'resume.html')


# Convert to PDF using Pagedown
taroutput = paste0("resume_TAR_CV_",lubridate::year(Sys.Date()),".pdf")
pagedown::chrome_print(input = 'resume.html',
                       output = taroutput)

