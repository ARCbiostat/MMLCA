
# I need to create theta=f(theta2) on the omega dimension (D)--> maps from K dimension



# Initial parameters needs to be on the dimensions of omega
# actually my initial par e return par are dimensions for Lamda (the one I am interested in)
# I need to calculate 


# Likelihood for Omegas (theta)
Loglik(
  K = K, # number of markers
  nD = nD, # number of omegas
  mapping =  mapping.to.LP,
  paraOpt = paras$paraOpt,
  paraFixe = paras$paraFixe,
  posfix = paras$posfix,
  paras_k = paras$npara_k,
  sequence = as.matrix(paras$sequence),
  type_int = paras$type_int,
  ind_seq_i = paras$ind_seq_i,
  MCnr = MCnr,
  nmes = nmes,
  m_is = data$m_i,
  Mod_MatrixY = data$Mod.MatrixY,
  Mod_MatrixYprim = data$Mod.MatrixYprim,
  df = data$df,
  x = data$x,
  z = data$z,
  q = data$q,
  nb_paraD = data$nb_paraD,
  x0 = data$x0,
  z0 = data$z0,
  q0 = data$q0,
  cholesky = cholesky,
  data_surv = as.matrix(data_surv),
  data_surv_intY = as.matrix(data$intYsurv),
  nYsurv = data$nYsurv,
  basehaz = ifelse(paras$basehaz == "Weibull", 0, 1),
  knots_surv = paras$knots_surv,
  np_surv = paras$np_surv,
  survival = (data$nE > 0),
  assoc =  paras$assoc,
  truncation = paras$truncation,
  nE = data$nE,
  Xsurv1 = as.matrix(data$Xsurv1),
  Xsurv2 = as.matrix(data$Xsurv2),
  if_link = if_link,
  zitr = data$zitr,
  ide = data$ide,
  tau = data$tau,
  tau_is = data$tau_is,
  modA_mat = data$modA_mat,
  DeltaT,
  ii = length(data$m_i) + 10
)