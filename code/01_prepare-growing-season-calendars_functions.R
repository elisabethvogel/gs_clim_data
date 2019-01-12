# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 21/05/2018
#
# This file contains functions for preparation of growing season calendars.
#
# These functions require the package "netcdf.conversions".
# Installation:
# install.packages("dev.tools")
# devtools::install_github("elisabethvogel/netcdf.conversions", quiet = TRUE)
library(netcdf.conversions)
library(plyr)
library(dplyr)

###############################################################################
# Set file paths

project_path = "." # define location of overall project path (relative or absolute path)
calendars_path = file.path(project_path, "data/raw_data/crop_calendars")
calendars_outpath = file.path(project_path, "data/processed_data/crop_calendars")
dir.create(calendars_outpath, showWarnings = FALSE, recursive = TRUE)

###############################################################################
prepare_sacks_crop_calendar = function(crop = NULL, ifile = NULL, ofile = NULL,
                                       prepare_monthly = TRUE,
                                       verbose = FALSE) {
  
  if (verbose) print("function: prepare_sacks_crop_calendar")
  if (verbose) print(sprintf("crop: %s, monthly: %s", 
                             crop, prepare_monthly))
  
  stopifnot(!is.null(crop) || (!is.null(ifile) && !is.null(ofile)))
  stopifnot(crop %in% c("Maize", "Maize.2", "Rice", "Rice.2", 
                        "Soybeans", "Wheat", "Wheat.Winter"))
  
  if (is.null(ifile)) {
    input_path = file.path(calendars_path, "sacks_crop_calendar/data/sacks_crop_calendar_0.5/netcdf")
    ifile = file.path(input_path, sprintf("%s.crop.calendar.nc", crop))
  }
  if (is.null(ofile)) {
    output_path = file.path(calendars_outpath, "sacks_crop_calendar")
    # create new crop name (lower case and with '_' instead of '.')
    crop_new = gsub(".", "_", tolower(crop), fixed = TRUE)
    ofile = file.path(output_path, sprintf("sacks_crop_calendar_%s.nc", crop_new))
  }
  
  # read in data (only plant and harvest)
  if (verbose) print("Reading in planting and harvest data.")
  df = netcdf2dataframe(netcdf_file = ifile, variables = c("plant", "harvest"))
  
  # round latitude/longitude (due to precision, the values are not correct)
  df$latitude = round(df$latitude, 3)
  df$longitude = round(df$longitude, 3)
  
  # prepare monthly values
  if (prepare_monthly) {
    if (verbose) print("Preparing monthly values.")
    df = prepare_monthly_from_daily_calendar(df)
  }
  
  # save data
  if (verbose) print(sprintf("Saving data to: %s.", ofile))
  if (prepare_monthly) {
    fn = dataframe2netcdf(data_frame = df, netcdf_file = ofile,
                          var_names = c("plant", "harvest"),
                          var_units = c("month", "month"),
                          var_longnames = c("planting month", "harvest month"),
                          overwrite_existing = TRUE)
  } else {
    fn = dataframe2netcdf(data_frame = df, netcdf_file = ofile,
                          var_names = c("plant", "harvest"),
                          var_units = c("day of year", "day of year"),
                          var_longnames = c("planting day", "harvest day"),
                          overwrite_existing = TRUE)
  }
  if (verbose) print("Finished.")
}

###############################################################################
prepare_mirca2000_crop_calendar = function(crop = NULL, irrigation,
                                           ifile = NULL, ofile = NULL,
                                           verbose = FALSE) {
  
  if (verbose) print("function: prepare_mirca2000_crop_calendar")
  if (verbose) print(sprintf("crop: %s, irrigation: %s", 
                             crop, irrigation))
  
  stopifnot(!is.null(crop))
  stopifnot(irrigation %in% c("rainfed", "irrigated", "combined"))
  stopifnot(crop %in% c("wheat", "maize", "rice", "soybeans"))
  
  if (is.null(ifile)) {
    input_path = file.path(calendars_path, "mirca2000/data/cell_specific_cropping_calendars")
    ifile = file.path(input_path, "CELL_SPECIFIC_CROPPING_CALENDARS_30MN.TXT")
  }
  if (is.null(ofile)) {
    crop = tolower(crop)
    output_path = file.path(calendars_outpath, "mirca2000_crop_calendar")
    ofile = file.path(output_path, sprintf("mirca_crop_calendar_%s_%s.nc",
                                           crop, irrigation))
  }
  
  # read in data
  if (verbose) print("Reading in planting and harvest data.")
  mirca_data = read.csv(ifile, sep = "")
  mirca_data$plant = mirca_data$start
  mirca_data$harvest = mirca_data$end
  mirca_data$code = mirca_data$crop
  mirca_data = mirca_data[, c("lat", "lon", "code", "subcrop", "area", "plant", "harvest"), ]
  
  # read MIRCA crop codes
  if (verbose) print("Reading in MIRCA crop codes and filter calendar data.")
  crop_codes = read.csv(file.path(input_path, "/mirca_crop_codes.csv"))
  crop_codes$crop = tolower(crop_codes$crop)
  mirca_data = left_join(mirca_data, crop_codes, by = "code")
  
  # filter data by crop
  mirca_data = mirca_data[mirca_data$crop == crop, ]
  
  # for each grid cell, alculate total area and choose planting / harvest of
  # sub-crop with largest cropping area
  if (verbose) print("Choose planting/harvest from sub-crop with largest cropping area.")
  df = ddply(mirca_data, c("lon", "lat", "irrigation"),
             .fun = function(x)
               data.frame(area_total = sum(x$area), # over all sub-crops
                          plant = x$plant[which(x$area == max(x$area))][1],
                          harvest = x$harvest[which(x$area == max(x$area))][1]))
  
  df$plant[df$plant <= 0] = NA
  df$harvest[df$harvest <= 0] = NA
  
  if (irrigation %in% c("rainfed", "irrigated")) {
    df = df[df$irrigation == irrigation, ]
  } else if (irrigation == "combined") {
    if (verbose) print("Choosing planting/harvest from irrigation type with largest cropping area.")
    # select for each
    df = ddply(df, c("lon", "lat"),
               .fun = function(x) {
                 x = x[which(x$area == max(x$area))[1], ]
                 return(x)})
  }
  
  # save data
  if (verbose) print(sprintf("Saving data to: %s.", ofile))
  fn = dataframe2netcdf(data_frame = df, netcdf_file = ofile,
                        var_names = c("plant", "harvest"),
                        var_units = c("month", "month"),
                        var_longnames = c("planting month", "harvest month"),
                        overwrite_existing = TRUE)
  
  if (verbose) print("Finished.")
}


###############################################################################
prepare_agmip_crop_calendar = function(crop = NULL, irrigation,
                                       ifile = NULL, ofile = NULL,
                                       prepare_monthly = TRUE,
                                       verbose = FALSE) {
  
  if (verbose) print("function: prepare_agmip_crop_calendar")
  if (verbose) print(sprintf("crop: %s, irrigation: %s, monthly: %s", 
                             crop, irrigation, prepare_monthly))
  
  stopifnot(!is.null(crop))
  stopifnot(irrigation %in% c("rainfed", "irrigated", "combined"))
  stopifnot(crop %in% c("Wheat", "Soy", "Rice", "Maize"))
  
  crop_new = tolower(crop)
  if (crop_new == "soy") crop_new = "soybeans"
  
  if (is.null(ofile)) {
    output_path = file.path(calendars_outpath, "agmip_v1.0_crop_calendar")
    ofile = file.path(output_path, sprintf("agmip_crop_calendar_%s_%s.nc",
                                           crop_new, irrigation))
  }
  
  # helper function for reading in AgMIP CC data
  read_in_data = function(crop, ifile, irrigation) {
    # prepare input file path
    if (is.null(ifile)) {
      if (irrigation == "rainfed") irpat = "rf"
      if (irrigation == "irrigated") irpat = "ir"
      input_path = file.path(calendars_path, "AGMIP_GROWING_SEASON.HARM.version1.0")
      ifile = file.path(input_path, sprintf("%s_%s_growing_season_dates.nc4", crop, irpat))
    }
    # read in data
    df = netcdf2dataframe(netcdf_file = ifile, variables = c("planting day", "harvest day"))
    df$plant = df$`planting day`
    df$harvest = df$`harvest day`
    df = df[, c("lon", "lat", "plant", "harvest")]
    df$plant[df$plant <= 0] = NA
    df$harvest[df$harvest <= 0] = NA
    return(df)
  }
  
  
  if (verbose) print("Reading in planting and harvest data.")
  if (irrigation %in% c("rainfed", "irrigated")) {
    df = read_in_data(crop = crop, ifile = ifile, irrigation = irrigation)
    
  } else if (irrigation == "combined") {
    df_rf = read_in_data(crop = crop, ifile = NULL, irrigation = "rainfed")
    df_rf$irrigation = "rainfed"
    df_ir = read_in_data(crop = crop, ifile = NULL, irrigation = "irrigated")
    df_ir$irrigation = "irrigated"
    df = rbind(df_rf, df_ir)
    df$lat = round(df$lat, 3)
    df$lon = round(df$lon, 3)
    
    # read in MIRCA data - which irrigation has the larger cropping area per grid cell?
    if (verbose) print("Choosing planting/harvest from irrigation type with largest cropping area.")
    largest_area = get_mirca2000_largest_area_harvest(crop = crop_new)
    largest_area$lat = round(largest_area$lat, 3)
    largest_area$lon = round(largest_area$lon, 3)
    # combine both datasets based on lat, lon and irrigation
    df = dplyr::inner_join(df, largest_area, by = c("lon", "lat", "irrigation"))
  }
  
  # prepare monthly values
  if (prepare_monthly) {
    if (verbose) print("Preparing monthly values.")
    df = prepare_monthly_from_daily_calendar(df)
  }
  
  # save data
  if (verbose) print(sprintf("Saving data to: %s.", ofile))
  if (prepare_monthly) {
    fn = dataframe2netcdf(data_frame = df, netcdf_file = ofile,
                          var_names = c("plant", "harvest"),
                          var_units = c("month", "month"),
                          var_longnames = c("planting month", "harvest month"),
                          overwrite_existing = TRUE)
  } else {
    fn = dataframe2netcdf(data_frame = df, netcdf_file = ofile,
                          var_names = c("plant", "harvest"),
                          var_units = c("day of year", "day of year"),
                          var_longnames = c("planting day", "harvest day"),
                          overwrite_existing = TRUE)
  }
  if (verbose) print("Finished.")
}

###############################################################################
prepare_monthly_from_daily_calendar = function(df) {
  
  df$plant = round(df$plant)
  df$harvest = round(df$harvest)
  df$plant[df$plant == 0] = 1
  df$harvest[df$harvest == 0] = 1
  df$plant[df$plant == 366] = 365
  df$harvest[df$harvest == 366] = 365
  
  stopifnot(all(df$plant >= 1, na.rm = T), all(df$plant <= 365, na.rm = T))
  stopifnot(all(df$harvest >= 1, na.rm = T), all(df$harvest <= 365, na.rm = T))
  
  month = rep(1:12, times = c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
  df$plant = sapply(df$plant, function(x) month[x][1])
  df$harvest = sapply(df$harvest, function(x) month[x][1])
  
  return(df)
}


###############################################################################
get_mirca2000_largest_area_harvest = function(crop = NULL, ifile = NULL, 
                                              ofile = NULL) {
  
  stopifnot(!is.null(crop))
  stopifnot(crop %in% c("wheat", "maize", "rice", "soybeans"))
  
  if (is.null(ifile)) {
    input_path = file.path(calendars_path, "mirca2000/data/cell_specific_cropping_calendars")
    ifile = file.path(input_path, "CELL_SPECIFIC_CROPPING_CALENDARS_30MN.TXT")
  }
  if (is.null(ofile)) {
    output_path = file.path(project_path, "data/processed_data/landuse_data/mirca2000")
    dir.create(output_path, showWarnings = FALSE, recursive = TRUE)
    ofile_area = file.path(output_path, sprintf("mirca2000_cropping_area_%s.nc", crop))
    ofile_largest = file.path(output_path, sprintf("mirca2000_largest_area_%s.nc", crop))
  }
  
  # read in data
  mirca_data = read.csv(ifile, sep = "")
  mirca_data$code = mirca_data$crop
  mirca_data = mirca_data[, c("lat", "lon", "code", "subcrop", "area"), ]
  
  # read MIRCA crop codes
  crop_codes = read.csv(file.path(input_path, "/mirca_crop_codes.csv"))
  crop_codes$crop = tolower(crop_codes$crop)
  mirca_data = left_join(mirca_data, crop_codes, by = "code")
  
  # filter data by crop
  mirca_data = mirca_data[mirca_data$crop == crop, ]
  
  # for each grid cell, alculate total area per irrigation
  df = ddply(mirca_data, c("lon", "lat", "irrigation"),
             .fun = function(x)
               data.frame(area = sum(x$area)))
  df = reshape2::dcast(df, lon + lat ~ irrigation, value.var = "area")
  df[, c("area_rainfed", "area_irrigated")] = df[, c("rainfed", "irrigated")]
  df[, c("rainfed", "irrigated")] = NULL
  
  # save data
  dataframe2netcdf(df, ofile_area, 
                   var_names = c("area_rainfed", "area_irrigated"),
                   var_units = c("ha", "ha"), 
                   var_longnames =  c(sprintf("cropping area, rainfed %s", crop),
                                      sprintf("cropping area, irrigated %s", crop)),
                   fill_dimensions = TRUE, overwrite_existing = TRUE)
  
  # select for each the largest area
  df = df  %>%
    group_by(lon, lat) %>%
    mutate(total_area = sum(area_rainfed, area_irrigated, na.rm = T),
           area_frac_rainfed = area_rainfed / total_area,
           area_frac_irrigated = area_irrigated / total_area) %>%
    ungroup()
  df$area_frac_rainfed[is.na(df$area_frac_rainfed)] = 0
  df$area_frac_irrigated[is.na(df$area_frac_irrigated)] = 0
  df$largest_area = NA
  df$largest_area[df$area_frac_rainfed > 0.5] = -1
  df$largest_area[df$area_frac_irrigated > 0.5] = 1
  
  # save data  
  dataframe2netcdf(df, ofile_largest, var_names = "largest_area",
                   var_units = "-",
                   var_longnames = "largest area fraction (-1 = rainfed, +1 = irrigated)",
                   fill_dimensions = TRUE,
                   overwrite_existing = TRUE)
  
  df = select(df, lon, lat, irrigation = largest_area)
  df$irrigation[df$irrigation == -1] = "rainfed"
  df$irrigation[df$irrigation == 1] = "irrigated"
  
  return(df)
}
