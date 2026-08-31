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
# head(ctd[, c("lat", "lon", "temperature", "salinity", "chlorophyll_a",
#              "ph", "alkalinity")])

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

## ----layers-scored------------------------------------------------------------
# # Points with fewer scored variables may have less reliable scores
# summary(result$n_layers_scored)
# table(result$n_layers_scored)

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
# # Write five-band GeoTIFF and companion QGIS style file
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

## ----aragonite-check----------------------------------------------------------
# # Verify aragonite was auto-calculated and scored
# "omega_aragonite"  %in% names(result)      # column present
# "score_ph"         %in% names(result)      # pH scored
# "score_omega_aragonite" %in% names(result) # aragonite scored
# 
# # Distribution of omega_aragonite across Example Bay
# summary(result$omega_aragonite)

## ----aragonite-manual, eval = FALSE-------------------------------------------
# # Manual calculation: sensors gave pH only, alkalinity approximated
# df$alkalinity <- 2300   # µmol/kg — representative NE Atlantic value
# df$omega_aragonite <- calculate_aragonite(
#   pH          = df$ph,
#   alkalinity  = df$alkalinity,
#   temperature = df$temperature,
#   salinity    = df$salinity
# )

## ----variable-impact----------------------------------------------------------
# impact <- variable_impact(result, "ostrea_edulis")
# print(impact)

## ----variable-impact-explore--------------------------------------------------
# # Variables scoring below 0.5 are potential site limiters
# impact[impact$mean_score < 0.5, c("variable", "norm_weight_pct", "mean_score")]
# 
# # Variables with sparse data coverage
# impact[impact$pct_coverage < 80, c("variable", "pct_coverage")]

## ----area-summary-------------------------------------------------------------
# # Auto-estimate cell size from median nearest-neighbour spacing
# s <- area_summary(result, verbose = TRUE)

## ----area-summary-explore-----------------------------------------------------
# # Per-class breakdown
# s$class_summary[, c("class", "area_m2", "area_ha", "pct_total_area",
#                     "mean_suitability")]
# 
# # Totals
# s$total[c("surveyed_area_m2", "suitable_area_m2", "pct_suitable", "cell_size_m")]
# 
# # Contiguous patches of High + Moderate suitability
# head(s$patches)
# 
# # Patches meeting the OSPAR 100 m² viable area threshold
# viable <- s$patches[s$patches$viable, ]
# cat(nrow(viable), "viable patches; largest:", round(max(viable$area_m2)), "m²\n")

## ----area-summary-known, eval = FALSE-----------------------------------------
# # 5 m ROV grid survey
# s5m <- area_summary(result, cell_size_m = 5, viable_area_m2 = 100)
# 
# # 25 m ADCP trackline survey, larger minimum viable unit for production scale
# s25m <- area_summary(result, cell_size_m = 25, viable_area_m2 = 500)

## ----plot-tolerance-temp, fig.height = 5--------------------------------------
# # Temperature scoring curve with zone shading
# plot_tolerance("ostrea_edulis", "temperature")

## ----plot-tolerance-seasons, fig.height = 5-----------------------------------
# # All four seasons overlaid on a single plot
# plot_tolerance("ostrea_edulis", "temperature", season = "all")

## ----plot-tolerance-oa, fig.height = 5----------------------------------------
# # Ocean acidification variables
# plot_tolerance("ostrea_edulis", "ph")
# plot_tolerance("ostrea_edulis", "omega_aragonite")

## ----plot-tolerance-do, fig.height = 5----------------------------------------
# # Dissolved oxygen: compare tolerance between species
# plot_tolerance("ostrea_edulis",        "dissolved_oxygen")
# plot_tolerance("crassostrea_iredalei", "dissolved_oxygen")

## ----plot-tolerance-save, eval = FALSE----------------------------------------
# p <- plot_tolerance("ostrea_edulis", "salinity")
# ggplot2::ggsave("salinity_tolerance_O_edulis.png", p, width = 8, height = 5)

## ----session-info-------------------------------------------------------------
# sessionInfo()

