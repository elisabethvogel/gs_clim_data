# Function: calculate_gs_climate
#
# This function calculates the annual mean growing season data from:
# a) a climate input dataset (netcdf), and
# b) a growing season calendar (netcdf) containing planting and harvest dates.
# Both files have to have the same resolution and latitudes / longitudes.
#
# This function requires the package "netcdf.conversions".
# Installation:
# install.packages("dev.tools")
# devtools::install_github("elisabethvogel/netcdf.conversions", quiet = TRUE)
#
# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 22/05/2018

calculate_growing_season_climate = function(crop_calendar_nc, climate_nc,
                                            output_nc, var, unit, 
                                            longname = var,
                                            time_agg = "month", 
                                            verbose = FALSE) {
  
  if (verbose) print("function: calculate_growing_season_climate")
  if (verbose) print(sprintf("Variable: %s", var))
  
  require(netcdf.conversions)
  require(dplyr)
  
  # read in data
  if (verbose) print("Reading in crop calendar and climate data.")
  crop_calendar = netcdf2dataframe(crop_calendar_nc, return_time_columns = TRUE,
                                   remove_NA = TRUE)
  climate_data = netcdf2dataframe(climate_nc, variables = var, 
                                  grid_cells = select(crop_calendar, lon, lat),
                                  return_time_columns = TRUE, years = 1961:2008)
  
  # check if crop calendar has time dimension
  if ("time" %in% names(crop_calendar)) {
    calendar_type = "dynamic"
    warning("Dynamic growing season calendars not tested yet.") # to do
  } else {
    calendar_type = "static"
  }
  
  # remove unneeded columns and calculate day_of_year, if applicable
  if (verbose) print("Prepare time columns in both datasets")
  climate_data = prepare_time_information(climate_data, time_agg = time_agg)
  crop_calendar = prepare_time_information(crop_calendar, time_agg = time_agg)
  
  if (time_agg == "month") {
    stopifnot(max(crop_calendar$plant, na.rm = T) <= 12)
    stopifnot(max(crop_calendar$harvest, na.rm = T) <= 12)
  } else if (time_agg == "day_of_year") {
    stopifnot(max(crop_calendar$plant, na.rm = T) <= 366)
    stopifnot(max(crop_calendar$harvest, na.rm = T) <= 366)
  }
  
  # standardise lat/lon names
  climate_data = standardise_lat_lon(climate_data)
  crop_calendar = standardise_lat_lon(crop_calendar)
  
  if (verbose) print("Merge both datasets")
  # merge both datasets
  if (calendar_type == "static") {
    aggregation_variables = c("lon", "lat")
  } else if (calendar_type == "dynamic") {
    aggregation_variables = c("lon", "lat", "year")
  }
  climate_data = dplyr::inner_join(climate_data, crop_calendar, 
                                   by = aggregation_variables)
  
  # adjust time information in grid cells where harvest is before planting
  # --> for all months >= planting, set year = year + 1, so that the year
  # is always the year of the harvest
  if (verbose) print("Adjust year in grid cells where plant > harvest (e.g. Southern Hemisphere).")
  climate_data = plyr::ddply(.data = climate_data,
                             .variables = aggregation_variables,
                             .fun = function(x) 
                               prepare_year_when_harvest_before_planting(x))
  
  # calculate growing season climate for every year
  if (verbose) print("Calculate growing season climate indices.")
  growing_season_climate = calculate_gs_climate(climate_data, var, time_agg, 
                                                verbose = verbose)
  
  # save netcdf file
  if (verbose) print("Save netcdf file.")
  fn = dataframe2netcdf(growing_season_climate, output_nc,
                   dim_names = c("lon", "lat", "time"), 
                   var_names = paste(var, "gs", c("min", "max", "mean", "n"), 
                                     sep = "_"),
                   var_units = rep(unit, 4),
                   var_longnames = rep(longname, 4),
                   fill_dimensions = TRUE,
                   overwrite_existing = TRUE)
  
  return(growing_season_climate)
}


###############################################################################
# Helper functions

calculate_gs_climate = function(df, var, time_agg, verbose = FALSE) {
  

  df$var = df[, var]
  df$time = df[, time_agg]
  
  # 1) calculate GS climate for grid cells where plant < harvest
  if (verbose) print("1) calculate GS climate for grid cells where plant < harvest")
  gs_clim_1 = df %>%
    filter(plant < harvest, !is.na(var)) %>%
    mutate(var = ifelse(time < plant | time > harvest, NA, var)) %>%
    filter(!is.na(var)) %>%
    group_by(lon, lat, year) %>%
    summarise(min = min(var), max = max(var), 
              mean = mean(var), n = sum(!is.na(var)))
  
  # 2) calculate GS climate for grid cells where plant > harvest
  if (verbose) print("2) calculate GS climate for grid cells where plant > harvest")
  gs_clim_2 = df %>%
    filter(plant > harvest, !is.na(var),
           # remove months from 1st GS, because planting is not included in data
           year != min(year, na.rm = TRUE),
           # remove months from last GS, because harvest is not included in data
           year != max(year, na.rm = TRUE)) %>%
    mutate(var = ifelse(time >= plant | time <= harvest, var, NA)) %>%
    filter(!is.na(var)) %>%
    group_by(lon, lat, year) %>%
    summarise(min = min(var), max = max(var), 
              mean = mean(var), n = sum(!is.na(var)))
  
  growing_season_climate = ungroup(rbind(gs_clim_1, gs_clim_2))
  growing_season_climate = arrange(growing_season_climate, lon, lat, year)
  
  # rename columns
  growing_season_climate[, paste(var, "gs", c("min", "mean", "max", "n"), sep = "_")] =
    growing_season_climate[, c("min", "mean", "max", "n")] 
  growing_season_climate[, c("min", "mean", "max", "n")] = NULL
  
  growing_season_climate$time = growing_season_climate$year
  growing_season_climate$year = NULL
  
  return(growing_season_climate)
  
}

prepare_time_information = function(df, time_agg = NULL) {
  
  if (! "time" %in% names(df)) {
    # no time data --> no preparation needed
    return(data.frame(df))
  }
  
  # prepare time information
  if (length(unique(df$month)) == 1) {
    # dynamic crop calendars, keep only year information
    df[, c("time", "POSIXct", "month", "day", "hour", "minute", "second", "origin", "unit", "vals")] = NULL
    return (df)
  }
  
  if (is.null(time_agg)) {
    if (length(unique(df$day)) == 1) {
      time_agg = "month"
    } else if (length(unique(df$day) > 1))
      time_agg = "day_of_year"
  }
  
  if (time_agg == "month") {
    # climate data with monthly time aggregation, keep only year, month information
    df[, c("time", "POSIXct", "day", "hour", "minute", 
           "second", "origin", "unit", "vals")] = NULL
  } else if (time_agg == "day_of_year") {
    # climate data with daily time aggregation, calculate day of year from month and day
    df$day_of_year = lubridate::yday(df$POSIXct)
    # keep only year and day_of_year columns
    df[, c("time", "POSIXct", "month", "day", "hour", "minute",
           "second", "origin", "unit", "vals")] = NULL
  }
  return(df)
}

standardise_lat_lon = function(df) {
  if ("latitude" %in% names(df)) df = rename(df, lat = latitude)
  if ("longitude" %in% names(df)) df = rename(df, lon = longitude)
  return(df)
}

prepare_year_when_harvest_before_planting = function(df, 
                                                     plant = unique(df$plant),
                                                     harvest = unique(df$harvest)) {
  if (is.na(plant) || is.na(harvest)) return(df)
  if (harvest >= plant) return(df)
  # if harvest < plant: year=year+1 for all months after planting
  df$year[df$month >= plant] = df$year[df$month >= plant] + 1
  return(df)
}

