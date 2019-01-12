#!/bin/bash

# This script will run all scripts of the analysis to prepare growing season climate data.
#
# Elisabeth Vogel, elisabeth.vogel@climate-energy-college.org
# 21/05/2018

###############################################################################
project_path=`dirname "$0"/..` # set location of project path - relative or absolute
cd ${project_path}

# Step 1: Prepare growing season calendars
Rscript code/01_prepare-growing-season-calendars.R

# Step 2: Prepare climate datasets
sh code/02_prepare-climate-input-data.sh

# Step 3: Calculate growing season climate data
Rscript code/03_calculate-growing-season-climate.R
