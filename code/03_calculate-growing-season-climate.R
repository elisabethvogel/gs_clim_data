# This script calculates the annual mean growing season data from:
# a) a climate input dataset (netcdf), and
# b) a growing season calendar (netcdf) containing planting and harvest dates.
# Both files have to have the same resolution and latitudes / longitudes.
#
# This function requires the package "netcdf.conversions".
# Installation:
# install.packages("dev.tools")
# devtools::install_github("evbln/netcdf.conversions", quiet = TRUE)
#
# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 22/05/2018


project_path = "." # define location of overall project path (relative or absolute path)
source(file.path(project_path, "code/data_preparation/03_calculate-growing-season-climate_functions.R"))

verbose = TRUE

###############################################################################
# 1) Prepare growing season data for CRU TS 3.23

crop_calendar_path = file.path(project_path, "data/processed_data/crop_calendars/agmip_v1.0_crop_calendar")
cru_ts_path = file.path(project_path, "data/processed_data/climate_data/cru_ts_323")
out_path = file.path(project_path, "data/processed_data/growing_season_climate/cru_ts_323")
dir.create(out_path, showWarnings = FALSE, recursive = TRUE)

crops = c("maize", "wheat", "soybeans", "rice")
vars = c("tmp", "pre", "dtr", "frs")
units = c("degrees Celsius", "mm/month", "degrees Celsius", "days")
longnames = c("temperature", "precipitation", "diurnal temperature range", "ground frost frequency")
irrigation = "combined"

for (crop in crops) {
  for(var in vars) {
    
    unit = units[vars == var]
    longname = longnames[vars == var]
    
    crop_calendar_nc = file.path(crop_calendar_path,
                                 sprintf("agmip_crop_calendar_%s_%s.nc", crop, irrigation))
    climate_nc = file.path(cru_ts_path,
                           sprintf("cru_ts323_%s_1961_2014.nc", var))
    output_nc = file.path(out_path,
                          sprintf("%s_%s_cru_ts_323_%s_gs.nc",
                                  crop, irrigation, var))
    
    calculate_growing_season_climate(crop_calendar_nc, climate_nc,
                                     output_nc, var, unit, longname,
                                     time_agg = "month", verbose = verbose)
  }
}

###############################################################################
# 2) Prepare growing season data for HADEX2

crop_calendar_path = file.path(project_path, "data/processed_data/crop_calendars/agmip_v1.0_crop_calendar")
hadex2_path = file.path(project_path, "data/processed_data/climate_data/hadex2")
out_path = file.path(project_path, "data/processed_data/growing_season_climate/hadex2")
dir.create(out_path, showWarnings = FALSE, recursive = TRUE)

crops = c("maize", "wheat", "soybeans", "rice")
vars = c("DTR", "Rx1day", "Rx5day", "TN10p", "TN90p", "TNn", "TNx", "TX10p", "TX90p", "TXn", "TXx")
units = c("degrees Celsius", "mm", "mm", "%", "%",  "degrees Celsius",  "degrees Celsius",
          "%", "%",  "degrees Celsius", "degrees Celsius")
longnames = vars
irrigation = "combined"

for (crop in crops) {
  for(var in vars) {
    
    unit = units[vars == var]
    longname = longnames[vars == var]
    
    crop_calendar_nc = file.path(crop_calendar_path, 
                                 sprintf("agmip_crop_calendar_%s_%s.nc", crop, irrigation))
    climate_nc = file.path(hadex2_path, 
                           sprintf("hadex2_%s_1961-2008_0.5deg.nc", var))
    output_nc = file.path(out_path, 
                          sprintf("%s_%s_hadex2_%s_gs.nc", 
                                  crop, irrigation, var))
    
    calculate_growing_season_climate(crop_calendar_nc, climate_nc,
                                     output_nc, var, unit, longname,
                                     time_agg = "month", verbose = verbose)
  }
}