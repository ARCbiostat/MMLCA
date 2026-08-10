# MMLCA 1.0

## April 2025 
- basic functions to run LCA

## May 2025  
- added assignment to LCA, spaghetti plot and alluvial

## June 2025 -
- added function for multiple imputated datasets for subject assignment and 95% CI to O/E

## Dec 2025
 TO DO:
 - make it more general not only diseases
 - insted of prefix in prepare_data use number columns
 - make keepMM in prepare more general (for example exclude people who don't have any of the conditions)
 - fix train/test
 - alluvial to compare solutions with multiple imputation

# MMLCA 2.0
## August 2026
- functions renamed for consistency, old ones are mantained for backward compatibility
- alluvial moved to package for longitudinal analyses
- prepare_data more general
- train/test removed, together with cv. Now we use the concept of stability
