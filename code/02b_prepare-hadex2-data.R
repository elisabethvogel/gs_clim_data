# Prepare HADEX2 netcdf files with one variable and one time dimension (instead of one variable per month)
# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 21/05/2018
#
# These functions require the package "netcdf.conversions".
# Installation:
# install.packages("dev.tools")
# devtools::install_github("elisabethvogel/netcdf.conversions", quiet = TRUE)

project_path = "." # define location of overall project path (relative or absolute path)

# Set path to hadex2 files
hadex2_path = file.path(project_path, "data/raw_data/climate_data/hadex2/hadex2_gridded_data")

# Set output path
output_path = file.path(project_path, "data/processed_data/climate_data/extreme_indicators/hadex2_gridded_data")

verbose = TRUE

###############################################################################
# Function definition
prepare_hadex2 = function(climate_indicator = NULL, ifile = NULL, ofile = NULL,
                          verbose = FALSE) {
  
  require(chron)
  require(ncdf4)
  require(dplyr)
  require(netcdf.conversions)
  
  if (verbose) print("function: prepare_hadex2")
  if (verbose) print(sprintf("Climate index: %s", climate_indicator))
  
  if (is.null(ifile)) {
    filename = sprintf("H2_%s_1901-2010_RegularGrid_global_3.75x2.5deg_LSmask.nc", climate_indicator)
    ifile = file.path(hadex2_path, filename)
  }
  if (is.null(ofile)) {
    output_path = file.path(project_path, "data/processed_data/climate_data/hadex2")
    filename = sprintf("hadex2_%s_1961-2008.nc", climate_indicator)
    ofile = file.path(output_path, filename)
  }
  
  years = 1901:2010
  n_years = length(years)
  new_time_vals = julian(d = rep(15, 12 * n_years),
                         x = rep(1:12, n_years),
                         y = rep(1901:2010, rep(12, n_years)), 
                         origin. = c(month = 1, day = 1, year = 1900))
  
  # read data
  data_nc = nc_open(ifile)
  lon_dim = data_nc$dim$lon
  lat_dim = data_nc$dim$lat
  lon_size = lon_dim$len
  lat_size = lat_dim$len
  units = data_nc$var$Jan$units
  
  data_var = list()
  for (month in month.abb) {
    data_var[[month]] = ncvar_get(data_nc, month)
  }
  
  # create new empty data array
  data_var_new = array(NA, c(lon_size, lat_size, n_years * 12))
  counter = 1
  for (year_idx in 1:n_years) {
    for (month in month.abb) {
      data_var_new[, , counter] = data_var[[month]][, , year_idx]
      counter = counter + 1
    }
  }
  
  # create new netcdf file
  ofile_temp = gsub(".nc", "_temp.nc", x = ofile, fixed = TRUE)
  
  dir.create(output_path, showWarnings = FALSE, recursive = TRUE)
  time_dim = ncdim_def("time", "days since 1900-1-1",
                       new_time_vals, unlim = TRUE, calendar = "gregorian")
  data_var_nc = ncvar_def(name = climate_indicator, units = units, 
                          dim = list(lon_dim, lat_dim, time_dim), prec = "double")
  data_new_nc = nc_create(filename = ofile_temp, vars = data_var_nc)
  ncvar_put(nc = data_new_nc, varid = climate_indicator, vals = data_var_new)
  nc_close(data_new_nc)
  rm(data_var_new)
  
  # read in this temporary netcdf file as data frame (1961-2008 only)
  df = netcdf2dataframe(ofile_temp, years = 1961:2008)
  
  # adjust latitude coordinate: lat from -90 to 90, instead of 0 to 180
  df$lat[df$lat > 90] = df$lat[df$lat > 90] - 180
  df$lon[df$lon > 180] = df$lon[df$lon > 180] - 360
  fn = dataframe2netcdf(df, ofile, dim_names = c("lon", "lat", "time"), 
                        overwrite_existing = TRUE)
  
  # remove temporary file
  file.remove(ofile_temp)
}

###############################################################################
# Start

print("Reorder climate extreme indicator datasets for HADEX2")
print("- instead of different variables for each month --> different variables for each data type")

# climate_indicators = c("DTR", "TN10p", "TN90p", "TNn", "TNx", "TX10p", 
#                       "TX90p", "TXn", "TXx", "Rx1day", "Rx5day")

# Example for TNn
climate_indicators = c("TNn")

for(climate_indicator in climate_indicators){
  prepare_hadex2(climate_indicator = climate_indicator, verbose = verbose)
}

print("Completed...")
