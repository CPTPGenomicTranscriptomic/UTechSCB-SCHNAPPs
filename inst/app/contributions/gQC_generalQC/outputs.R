# source("moduleServer.R", local = TRUE)
# source("reactives.R", local = TRUE)

# TODO: verify that this anything and then integrate in DUMMY
myZippedReportFiles <- c("gqcProjections.csv")



.schnappsEnv$gQC_X1 <- "tsne1"
.schnappsEnv$gQC_X2 <- "tsne2"
.schnappsEnv$gQC_X3 <- "tsne3"
.schnappsEnv$gQC_col <- "sampleNames"
observe(label = "ob2", {
  if (DEBUG) cat(file = stderr(), "observe: gQC_dim3D_x\n")
  .schnappsEnv$gQC_X1 <- input$gQC_dim3D_x
})
observe(label = "ob3", {
  if (DEBUG) cat(file = stderr(), "observe: gQC_dim3D_y\n")
  .schnappsEnv$gQC_X2 <- input$gQC_dim3D_y
})
observe(label = "ob4", {
  if (DEBUG) cat(file = stderr(), "observe: gQC_dim3D_z\n")
  .schnappsEnv$gQC_X3 <- input$gQC_dim3D_z
})
observe(label = "ob5", {
  if (DEBUG) cat(file = stderr(), "observe: gQC_col3D\n")
  .schnappsEnv$gQC_col <- input$gQC_col3D
})

# gQC_update3DInput ----
#' gQC_update3DInput
#' update axes for tsne display
gQC_update3DInput <- reactive({
  if (DEBUG) cat(file = stderr(), "gQC_update3DInput started.\n")
  start.time <- base::Sys.time()
  on.exit({
    printTimeEnd(start.time, "gQC_update3DInput")
    if (!is.null(getDefaultReactiveDomain())) {
      removeNotification(id = "gQC_update3DInput")
    }
  })
  if (!is.null(getDefaultReactiveDomain())) {
    showNotification("gQC_update3DInput", id = "gQC_update3DInput", duration = NULL)
  }

  projections <- projections()

  # Can use character(0) to remove all choices
  if (is.null(projections)) {
    return(NULL)
  }
  # choices = colnames(projections)[unlist(lapply(colnames(projections), function(x) !is.factor(projections[,x])))]
  choices <- colnames(projections)
  # Can also set the label and select items
  updateSelectInput(session, "gQC_dim3D_x",
    choices = choices,
    selected = .schnappsEnv$gQC_X1
  )

  updateSelectInput(session, "gQC_dim3D_y",
    choices = choices,
    selected = .schnappsEnv$gQC_X2
  )
  updateSelectInput(session, "gQC_dim3D_z",
    choices = choices,
    selected = .schnappsEnv$gQC_X3
  )
  updateSelectInput(session, "gQC_col3D",
    choices = colnames(projections),
    selected = .schnappsEnv$gQC_col
  )
})

# observer of UMAP button ----
observe(label = "ob_UMAPParams", {
  # save(file = "~/SCHNAPPsDebug/ob_UMAPParams.RData", list = c(ls(), ".schnappsEnv"))
  # load("~/SCHNAPPsDebug/updateButtonColor.RData")
  # browser()
  if (DEBUG) cat(file = stderr(), "observe umapVars\n")
  
  input$activateUMAP
  setRedGreenButtonCurrent(
      vars = list(
        c("gQC_um_randSeed", input$gQC_um_randSeed),
        c("gQC_um_n_neighbors", input$gQC_um_n_neighbors),
        c("gQC_um_n_components", input$gQC_um_n_components),
        c("gQC_um_n_epochs", input$gQC_um_n_epochs),
        # c("um_alpha", input$um_alpha),
        c("gQC_um_init", input$gQC_um_init),
        c("gQC_um_min_dist", input$gQC_um_min_dist),
        c("gQC_um_set_op_mix_ratio", input$gQC_um_set_op_mix_ratio),
        c("gQC_um_local_connectivity", input$gQC_um_local_connectivity),
        c("gQC_um_bandwidth", input$gQC_um_bandwidth),
        c("um_gamma", input$um_gamma),
        c("gQC_um_negative_sample_rate", input$gQC_um_negative_sample_rate),
        c("gQC_um_metric", input$gQC_um_metric),
        c("gQC_um_spread", input$gQC_um_spread)
      )
    )
    
  updateButtonColor(buttonName = "activateUMAP", parameters = c(
    "gQC_um_randSeed", "gQC_um_n_neighbors", "gQC_um_n_components", "gQC_um_n_epochs", 
    "gQC_um_init", "gQC_um_min_dist", "gQC_um_set_op_mix_ratio", 
    "gQC_um_local_connectivity", "gQC_um_bandwidth", "um_gamma", 
    "gQC_um_negative_sample_rate", "gQC_um_metric", "gQC_um_spread"
  ))
})



# observe: cellNameTable_rows_selected ----
observe(label = "ob_tsneParams", {
  if (DEBUG) cat(file = stderr(), "observe tsneVars\n")
  out <- tsne()
  if (is.null(out)) {
    .schnappsEnv$calculated_gQC_tsneDim <- "NA"
  }
  input$updatetsneParameters

  setRedGreenButtonCurrent(
    vars = list(
      c("gQC_tsneDim", input$gQC_tsneDim),
      c("gQC_tsnePerplexity", input$gQC_tsnePerplexity),
      c("gQC_tsneTheta", input$gQC_tsneTheta),
      c("gQC_tsneSeed", input$gQC_tsneSeed)
    )
  )
  updateButtonColor(buttonName = "updatetsneParameters", parameters = c(
    "gQC_tsneDim", "gQC_tsnePerplexity",
    "gQC_tsneTheta", "gQC_tsneSeed"
  ))
})

# gQC_tsne_main ----
output$gQC_tsne_main <- plotly::renderPlotly({
  if (DEBUG) cat(file = stderr(), "gQC_tsne_main started.\n")
  start.time <- base::Sys.time()
  on.exit({
    printTimeEnd(start.time, "gQC_tsne_main")
    if (!is.null(getDefaultReactiveDomain())) {
      removeNotification(id = "gQC_tsne_main")
    }
  })
  if (!is.null(getDefaultReactiveDomain())) {
    showNotification("gQC_tsne_main", id = "gQC_tsne_main", duration = NULL)
  }

  upI <- gQC_update3DInput()
  projections <- projections()
  dimX <- input$gQC_dim3D_x
  dimY <- input$gQC_dim3D_y
  dimZ <- input$gQC_dim3D_z
  dimCol <- input$gQC_col3D
  scols <- sampleCols$colPal
  ccols <- clusterCols$colPal

  if (is.null(projections)) {
    if (DEBUG) cat(file = stderr(), "output$gQC_tsne_main:NULL\n")
    return(NULL)
  }
  if (.schnappsEnv$DEBUGSAVE) {
    save(file = "~/SCHNAPPsDebug/gQC_tsne_main.RData", list = c(ls()))
  }
  # load(file="~/SCHNAPPsDebug/gQC_tsne_main.RData")

  retVal <- tsnePlot(projections, dimX, dimY, dimZ, dimCol, scols, ccols)

  exportTestValues(tsnePlot = {
    str(retVal)
  })
  layout(retVal)
})

# gQC_umap_main 2D plot ----
callModule(
  clusterServer,
  "gQC_umap_main",
  projections
)

# gQC_projectionTableMod ----
callModule(
  tableSelectionServer,
  "gQC_projectionTableMod",
  projectionTable
)

# gQC_plotUmiHist ----
output$gQC_plotUmiHist <- renderPlot({
  if (DEBUG) cat(file = stderr(), "gQC_plotUmiHist started.\n")
  start.time <- base::Sys.time()
  on.exit({
    printTimeEnd(start.time, "gQC_plotUmiHist")
    if (!is.null(getDefaultReactiveDomain())) {
      removeNotification(id = "gQC_plotUmiHist")
    }
  })
  if (!is.null(getDefaultReactiveDomain())) {
    showNotification("gQC_plotUmiHist", id = "gQC_plotUmiHist", duration = NULL)
  }

  scEx <- scEx()
  scols <- sampleCols$colPal

  if (is.null(scEx)) {
    return(NULL)
  }
  if (.schnappsEnv$DEBUGSAVE) {
    save(file = "~/SCHNAPPsDebug/gQC_plotUmiHist.RData", list = c(ls()))
  }
  # load(file = "~/SCHNAPPsDebug/gQC_plotUmiHist.RData")

  dat <- data.frame(counts = Matrix::colSums(assays(scEx)[["counts"]]))
  dat$sample <- colData(scEx)$sampleNames
  retVal <- ggplot(data = dat, aes(counts, fill = sample)) +
    geom_histogram(bins = 50) +
    labs(title = "Histogram for raw counts", x = "count", y = "Frequency") +
    scale_fill_manual(values = scols, aesthetics = "fill")
  
  .schnappsEnv[["gQC_plotUmiHist"]] <- retVal
  return(retVal)
})

output$gQC_plotSampleHist <- renderPlot({
  if (DEBUG) cat(file = stderr(), "gQC_plotSampleHist started.\n")
  start.time <- base::Sys.time()
  on.exit({
    printTimeEnd(start.time, "gQC_plotSampleHist")
    if (!is.null(getDefaultReactiveDomain())) {
      removeNotification(id = "gQC_plotSampleHist")
    }
  })
  if (!is.null(getDefaultReactiveDomain())) {
    showNotification("gQC_plotSampleHist", id = "gQC_plotSampleHist", duration = NULL)
  }

  sampleInf <- sampleInfo()
  scols <- sampleCols$colPal

  if (is.null(sampleInf)) {
    return(NULL)
  }
  if (.schnappsEnv$DEBUGSAVE) {
    save(file = "~/SCHNAPPsDebug/sampleHist.RData", list = c(ls()))
  }
  # load(file = "~/SCHNAPPsDebug/sampleHist.RData")
  retVal <- gQC_sampleHistFunc(sampleInf, scols)
  .schnappsEnv[["gQC_plotSampleHist"]] <- retVal
  return(retVal)
})

output$gQC_variancePCA <- renderPlot({
  if (DEBUG) cat(file = stderr(), "gQC_variancePCA started.\n")
  start.time <- base::Sys.time()
  on.exit({
    printTimeEnd(start.time, "gQC_variancePCA")
    if (!is.null(getDefaultReactiveDomain())) {
      removeNotification(id = "gQC_variancePCA")
    }
  })
  if (!is.null(getDefaultReactiveDomain())) {
    showNotification("gQC_variancePCA", id = "gQC_variancePCA", duration = NULL)
  }
  pca <- pca()
  if (is.null(pca)) {
    return(NULL)
  }
  
  if (.schnappsEnv$DEBUGSAVE) {
    save(file = "~/SCHNAPPsDebug/gQC_variancePCA.RData", list = c(ls()))
  }
  # load(file = "~/SCHNAPPsDebug/gQC_variancePCA.RData")
  
  # h2("Variances of PCs")

 
  
  df <- data.frame(var = pca$var_pcs, pc = 1:length(pca$var_pcs))
  retVal <- ggplot(data = df,aes(x=pc, y=var)) + geom_bar(stat = "identity")  
  .schnappsEnv[["gQC_variancePCA"]] <- retVal
  return(retVal)
  # barplot(pca$var_pcs, main = "Variance captured by first PCs")
})
