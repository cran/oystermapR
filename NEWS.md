# oystermapR 1.4.0

## New species (9 added; 14 total)

* `crassostrea_virginica` — Eastern Oyster (NW Atlantic); high data quality.
* `saccostrea_glomerata` — Sydney Rock Oyster (E Australia); medium data quality.
* `magallana_sikamea` — Kumamoto Oyster (Japan / Pacific NW); low data quality.
* `magallana_ariakensis` — Suminoe Oyster (E Asia); low data quality.
* `crassostrea_hongkongensis` — Hong Kong Oyster (S China Sea); high data quality;
  note on historical misidentification as *C. plicatula* / *C. rivularis* included
  in species metadata.
* `crassostrea_nippona` — Iwagaki Oyster (Japan / Korea); medium data quality.
* `crassostrea_belcheri` — Tropical Rock Oyster (SE Asia); low data quality.
* `ostrea_chilensis` — Chilean Oyster (S Chile / New Zealand); low data quality.
* `ostrea_denselamellosa` — Korean Flat Oyster (E Asia); low data quality.

## New sensor readers (3 added)

* `read_nortek_aquadopp()` — reads Nortek Aquadopp ASCII export (ENU or beam
  files); handles moored (fixed lat/lon) and vessel-mounted (GPS in file) deployments.
* `read_rdi_adcp()` — reads Teledyne RDI binary PD0 files via `oce::read.adp.rdi()`;
  falls back to WinRiver ASCII CSV with `VelEast_binN` columns.
* `read_aanderaa_csv()` — reads Aanderaa Data Studio CSV exports; auto-detects
  speed unit (cm/s vs m/s); handles "Horisontal Speed" column name variant.

## Vignette

* Added `example-bay-survey` vignette: complete eight-step pipeline using simulated
  Example Bay data (ADCP, single-beam soundings, CTD), covering data ingest,
  QC, suitability prediction, risk scoring, and GeoTIFF export.
* Added three example data files to `inst/extdata/`:
  `example_bay_adcp.csv`, `example_bay_soundings.xyz`, `example_bay_ctd.csv`.

## Citation and documentation

* `inst/REFERENCES.md` expanded: added citations for all 9 new species; added
  Horn (1981) for terrain derivative methods; confirmed every referenced source
  in the package has a corresponding entry.
* Fixed pre-existing omission of *Ostrea lurida* from the species table in the
  bundled user-guide PDF.

---

# oystermapR 1.2.0

## Live data integration

* `oystermapR_live_config()` — stores credentials for CMEMS, ICES, EMODnet, and
  FSA in a session-scoped environment; credentials are never written to disk.
* `fetch_live_environmental_data()` — pulls salinity, temperature, current speed,
  chlorophyll, HAB presence, and substrate from external APIs and merges the
  result onto an existing survey dataframe by rounded lat/lon grid keys.
* CMEMS integration updated to copernicusmarine CLI v2.x: credentials via
  environment variables, removed `--force-download` / `--output-format csv`,
  `--log-level` changed to `WARN`; all output is NetCDF parsed with ncdf4.
* Multi-candidate dataset ID fallback: NWS north-west shelf regional product
  preferred; falls back to global 0.083-degree product automatically.

## Sensor ingest (new readers)

* `read_soundings_xyz()` — reads bathymetric sounding XYZ files; derives slope
  and rugosity via `terra::terrain`.
* `read_sonar_tif()` updated to normalise backscatter intensity to
  `substrate_hardness` in the range [0, 1]; reprojects to WGS84 if needed.

## Bug fixes

* `qc_survey_data()` — fixed crash when `apply_flags = TRUE`: `cli::cli_inform`
  bullet-prefix argument was incorrectly passed as a named function argument
  instead of a named element of the message character vector.
* `devtools::document()` warnings resolved: non-ASCII characters replaced with
  `\\uXXXX` escapes in R source; roxygen `#'` lines now use plain ASCII to
  avoid unknown-macro warnings in compiled `.Rd` files.

---

# oystermapR 1.1.0

## Season-aware scoring and tidal correction

* `detect_season()` / `add_season_column()` — automatic season detection from
  a datetime column; used internally by `predict_oyster()` to apply
  season-specific tolerance weights.
* `auto_tidal_correct()` / `correct_to_chart_datum()` — corrects depth readings
  to chart datum using harmonic tidal prediction (nodal factors, UKHO-style
  harmonics).
* `add_intertidal_flag()` — flags survey points that fall within the intertidal
  zone based on tidal range.

## Habitat and risk modules

* `score_hab_risk()` — HAB (Harmful Algal Bloom) risk scoring with optional live
  ICES biotoxin data integration.
* `score_anthropogenic_disturbance()` — disturbance scoring incorporating
  shipping density, aquaculture lease proximity, and dredging history layers.
* `score_wave_exposure()` / `score_sediment_stability()` — fetch-based wave
  exposure and Shields criterion sediment stability scoring.
* `add_shellfish_classification()` — appends EU/UK shellfish harvesting
  classification zone (A/B/C/Prohibited) from spatial polygon layers.

## Reporting

* `generate_summary_pdf()` — produces a self-contained four-page A4 PDF using
  only `grDevices::pdf()` and `ggplot2`; no LaTeX or pandoc dependency.

## Validation

* `validate_against_records()` now returns Brier score and F1 alongside AUC,
  TSS, sensitivity, and specificity.
* `spatial_block_cv()` spatial block cross-validation added.

---

# oystermapR 1.0.0

Initial CRAN release.

## Core prediction pipeline

* `predict_oyster()` — AHP-weighted suitability scoring from tabular sensor data,
  with automatic column name matching, season detection, hard exclusion checks,
  and optional GeoTIFF + contour export for QGIS.
* `check_exclusions()` / `score_locations()` — modular exclusion and scoring
  steps for programmatic use.
* `export_geotiff()` / `export_qml_style()` — raster and QGIS colour-ramp export.

## Species supported

Ostrea edulis, Magallana gigas, Crassostrea angulata, Ostrea stentina,
Ostrea lurida. See `list_species()`.

## Sensor ingest

* `read_nortek_adcp()` — Nortek Signature 500 ADCP CSV parser.
* `read_sonar_tif()` — Ping 3DSS / BioBase bathymetric raster reader.
* `merge_sensor_data()` / `ingest_sensors()` — spatial merge of multi-sensor datasets.

## Validation and diagnostics

* `validate_against_records()` — AUC, TSS, Brier score, F1, sensitivity/specificity
  vs known presence/absence records.
* `spatial_block_cv()` — spatial block cross-validation (Roberts et al. 2017).
* `permutation_importance()` — variable importance by AUC drop.
* `sensitivity_analysis()` — partial dependence curves.

## Bayesian tolerance updating

* `update_species_tolerances()` — MAP + Laplace or RWMH MCMC updating of
  optimal-range parameters from field observations.
* `get_tolerance_posteriors()`, `save_tolerance_update()`,
  `load_tolerance_update()`, `reset_tolerance_update()`.

## Risk and disturbance modules

* `score_predation_risk()`, `score_hab_risk()`,
  `score_anthropogenic_disturbance()`, `score_wave_exposure()`,
  `score_sediment_stability()`, `add_shellfish_classification()`.

## Larval connectivity

* `score_larval_connectivity()` — hybrid union-find Gaussian kernel + optional
  OpenDrift/FVCOM connectivity matrix scoring.
* `parse_opendrift_connectivity()` — converts OpenDrift CSV output to
  connectivity matrix format.

## Multi-species and seasonal comparison

* `compare_species()`, `compare_surveys()`, `composite_seasonal()`.
