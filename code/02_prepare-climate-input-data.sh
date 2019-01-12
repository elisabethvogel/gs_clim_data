#!/bin/bash

# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 21/05/2018
#
#
###############################################################################
#
# This script will prepare all climate data used in the preparation of
# growing season climate data.

# This script requires: NCO and CDO to process netcdf files.
# Installation instructions can be found under:
# NCO: http://nco.sourceforge.net/
# CDO: https://code.mpimet.mpg.de/projects/cdo
#

# The following climate datasets are processed:
#
# 1) CRU TS 3.23 dataset
# 2) HADEX2 dataset 

# References:
#
# 1) CRU TS 3.23
# - URL: https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_3.23/
# - Paper: Harris, I., Jones, P.D., Osborn, T.J. and Lister, D.H. (2014),
#   Updated high-resolution grids of monthly climatic observations – the CRU
#   TS3.10 Dataset. Int. J. Climatol., 34: 623–642. doi: 10.1002/joc.3711
#
# 2) HADEX2
# - URL: https://www.climdex.org/datasets.html
# - Paper: Donat, M. G., L. V. Alexander, H. Yang, I. Durre, R. Vose, R. J. H.
#   Dunn, K. M. Willett, E. Aguilar, M. Brunet, J. Caesar, B. Hewitson, C.
#   Jack, A. M. G. Klein Tank, A. C. Kruger, J. Marengo, T. C. Peterson, M.
#   Renom, C. Oria Rojas, M. Rusticucci, J. Salinger, A. S. Elrayah, S. S.
#   Sekele, A. K. Srivastava, B. Trewin, C. Villarroel, L. A. Vincent, P.
#   Zhai, X. Zhang and S. Kitching. 2013a. Updated analyses of temperature and
#   precipitation extreme indices since the beginning of the twentieth
#   century: The HadEX2 dataset, J. Geophys. Res. Atmos., 118, 2098–2118,
#   http://dx.doi.org/10.1002/jgrd.50150.



project_path="`dirname "$0"`/.." # set location of project path - relative or absolute
cd ${project_path}

###############################################################################
# 1) Prepare the CRU TS 3.23 dataset

hadcru_path=data/raw_data/climate_data/cru_ts_323/data
output_path=data/processed_data/climate_data/cru_ts_323

echo 'Preparing the CRU TS 3.23 data set'

var=tmp # tmp pre frs dtr

echo Variable: ${var}

mkdir -p ${output_path}/${var}

# for all data sets, merge all time steps together
echo 'Merging all time steps together'
ncrcat -h -O ${hadcru_path}/${var}/*.nc ${output_path}/cru_ts323_${var}_1961_2014.nc


###############################################################################
# 2) Prepare HADEX2 data
echo 'Preparing the HADEX2 data set'

Rscript code/02b_prepare-hadex2-data.R

wait

echo 'Regridding HADEX2 data set to 0.5 x 0.5 grid'

hadex2_path=data/processed_data/climate_data/hadex2
hadex2_grid=data/other/hadex2_grid.asc
new_grid=data/other/0.5_grid.asc

var=TNn # DTR Rx1day Rx5day TN10p TN90p TNn TNx TX10p TX90p TXn TXx; do

file=${hadex2_path}/hadex2_${var}_1961-2008.nc
# set lonlat grid (instead of generic grid)
cdo setgrid,${hadex2_grid} ${file} ${file%.nc}_temp.nc
cdo remapnn,${new_grid} ${file%.nc}_temp.nc ${file%.nc}_0.5deg.nc
rm ${file%.nc}_temp.nc



