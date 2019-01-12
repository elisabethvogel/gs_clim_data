# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 21/05/2018
#
#
###############################################################################
#
# This script will prepare all growing season calendars used in this analysis.
#
# 1) The Sacks et al. crop calendar
# 2) The MIRCA2000 crop calendar
# 3) The AgMIP v1.0 crop calendar

# References:

# 1) Sacks et al.
# - URL: https://nelson.wisc.edu/sage/data-and-models/crop-calendar-
#   dataset/index.php
# - Paper: Sacks, W.J., D. Deryng, J.A. Foley, and N. Ramankutty (2010). Crop
#   planting dates: an analysis of global patterns. Global Ecology and
#   Biogeography 19, 607-620. DOI: 10.1111/j.1466-8238.2010.00551.x.

# 2) MIRCA2000
# - URL: https://www.uni-frankfurt.de/45218031/data_download
# - Paper: Portmann, F. T., Siebert, S. & Döll, P. (2010): MIRCA2000 – Global
#   monthly irrigated and rainfed crop areas around the year 2000: A new high-
#   resolution data set for agricultural and hydrological modeling, Global
#   Biogeochemical Cycles, 24, GB 1011, doi:10.1029/2008GB003435.

# 3) AgMIP harmonised crop calendar v1.0
# - Paper: Elliott, J., C. Müller, D. Deryng, J. Chryssanthacopoulos, K.J.
#   Boote,
#   M. Büchner, I. Foster, M. Glotter, J. Heinke, T. Iizumi, R.C. Izaurralde,
#   N.D. Mueller, D.K. Ray, C. Rosenzweig, A.C. Ruane, and J. Sheffield, 2015:
#   The Global Gridded Crop Model Intercomparison: Data and modeling protocols
#   for Phase 1 (v1.0). Geosci. Model Dev., 8, 261-277,
#   doi:10.5194/gmd-8-261-2015.

###############################################################################

project_path = "." # define location of overall project path (relative or absolute path)
source(file.path(project_path, "code/data_preparation/01_prepare-growing-season-calendars_functions.R"))

verbose = TRUE
crop = "maize"
irrigation = "combined" # use the irrigation pattern with the largest area fraction per grid cell

###############################################################################
# 1) Prepare Sacks et al. crop calendar
prepare_sacks_crop_calendar(crop = tools::toTitleCase(crop), prepare_monthly = TRUE, verbose = verbose)

# 2) Prepare MIRCA et al. crop calendar
prepare_mirca2000_crop_calendar(crop = tolower(crop), irrigation = irrigation, verbose = verbose)

# 3) Prepare AgMIP harmonised crop calendar v1.0
prepare_agmip_crop_calendar(crop = tools::toTitleCase(crop), irrigation = irrigation,
                            prepare_monthly = TRUE, verbose = verbose)

