## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse  = TRUE,
  comment   = "#>",
  fig.width = 7,
  fig.height = 4,
  eval      = FALSE
)

## ----library------------------------------------------------------------------
# library(oystermapR)

## ----load-adcp----------------------------------------------------------------
# adcp_file <- system.file("extdata", "example_bay_adcp.csv", package = "oystermapR")
# 
# adcp <- read_nortek_adcp(
#   file        = adcp_file,
#   spatial_res = 2,
#   verbose     = TRUE
# )
# 
# head(adcp[, c("lat", "lon", "current_velocity", "shear_stress")])

## ----load-bathy---------------------------------------------------------------
# xyz_file <- system.file("extdata", "example_bay_soundings.xyz", package = "oystermapR")
# 
# bathy <- read_soundings_xyz(
#   file          = xyz_file,
#   spatial_res   = 2,
#   min_soundings = 5,
#   verbose       = TRUE
# )
# 
# head(bathy[, c("lat", "lon", "depth", "slope", "roughness")])

## ----load-ctd-----------------------------------------------------------------
# ctd_file <- system.file("extdata", "example_bay_ctd.csv", package = "oystermapR")
# 
# ctd <- read_generic_csv(
#   file        = ctd_file,
#   spatial_res = 2,
#   verbose     = TRUE
# )
# 
# head(ctd[, c("lat", "lon", "temperature", "salinity", "chlorophyll_a")])

## ----merge--------------------------------------------------------------------
# survey <- merge_sensor_data(adcp = adcp, bathy = bathy, ctd = ctd)
# 
# cat("Merged survey:", nrow(survey), "grid cells\n")
# cat("Columns:", paste(names(survey), collapse = ", "), "\n")

## ----add-substrate------------------------------------------------------------
# set.seed(101)
# n <- nrow(survey)
# # 0 = soft mud, 1 = hard rock; 0.3--0.7 = shell/gravel mix
# survey$substrate_hardness <- round(runif(n, 0.30, 0.70), 2)

## ----qc-----------------------------------------------------------------------
# survey_clean <- qc_survey_data(
#   df          = survey,
#   apply_flags = TRUE,
#   verbose     = TRUE
# )
# 
# # Count any flags raised across all columns
# flag_cols <- grep("^qc_flag_", names(survey_clean), value = TRUE)
# n_flagged <- sum(sapply(survey_clean[flag_cols], function(x) sum(!is.na(x) & x != "pass")))
# cat("Total flagged values replaced with NA:", n_flagged, "\n")

## ----predict, warning = FALSE-------------------------------------------------
# result <- predict_oyster(
#   data    = survey_clean,
#   species = "ostrea_edulis",
#   verbose = TRUE
# )
# 
# # Summary of suitability classes
# table(result$suitability_class)

## ----suitability-summary------------------------------------------------------
# # Mean score and range
# cat(sprintf(
#   "Suitability: mean = %.2f, range = %.2f -- %.2f\n",
#   mean(result$suitability, na.rm = TRUE),
#   min(result$suitability,  na.rm = TRUE),
#   max(result$suitability,  na.rm = TRUE)
# ))

## ----risk, warning = FALSE----------------------------------------------------
# # Wave exposure: uses current_velocity and depth as proxies for fetch exposure
# result <- score_wave_exposure(result, verbose = FALSE)
# 
# # HAB risk: without live ICES data, scores from chlorophyll_a alone
# result <- score_hab_risk(result, verbose = FALSE)
# 
# cat("Wave exposure range:", round(range(result$wave_exposure, na.rm=TRUE), 3), "\n")
# cat("HAB risk range:     ", round(range(result$hab_risk,      na.rm=TRUE), 3), "\n")

## ----export, eval = FALSE-----------------------------------------------------
# # Write GeoTIFF and companion QGIS style file
# export_geotiff(
#   df         = result,
#   path       = "example_bay_suitability.tif",
#   resolution = 0.001,
#   contours   = TRUE
# )
# export_qml_style("example_bay_suitability.tif")

## ----component-scores---------------------------------------------------------
# score_cols <- grep("^score_", names(result), value = TRUE)
# # Mean component score per variable (higher = more suitable)
# col_means <- sort(colMeans(result[score_cols], na.rm = TRUE))
# print(round(col_means, 3))

## ----session-info-------------------------------------------------------------
# sessionInfo()

