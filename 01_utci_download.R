cli::cli_h1(
  "Copernicus Climate Universal Thermal Climate Index download routine"
)

# Packages
library(ecmwfr)
library(lubridate)
library(stringr)
library(glue)
library(cli)
library(retry)
library(fs)

# Token
wf_set_key(key = Sys.getenv("era5_API_Key"))

# Parameters
dir_data <- "ntci_data/"
years <- "2024"
month <- str_pad(string = 1:12, width = 2, pad = "0")
day <- str_pad(string = 1:31, width = 2, pad = "0")

# Download loop
for (y in years) {
  for(m in months){
    # File name
  file_name <- glue(
    "clim_ntci_{y}.nc"
  )

  # Check if file is already available
  if (file.exists(paste0(dir_data, "/", file_name))) {
    cli_alert_warning("File already exists. Going for next.")
    next
  }

  # Declare request
  request <- list(
    dataset_short_name = "derived-utci-historical",
    variable = "universal_thermal_climate_index",
    version = "1_1",
    product_type = "consolidated_dataset",
    year = y,
    month = m,
    day = day,
    data_format = "netcdf",
    download_format = "unarchived",1
    # area = c(33.28, -118.47, -56.65, -34.1),
    target = file_name
  )

  # Download file with retry
  retry(
    expr = {
      wf_request(
        request = request,
        transfer = TRUE,
        path = dir_data
      )
    },
    interval = 1,
    until = ~ is_file(as.character(.))
  )
  }
}
