
  #GeneList <- c("ATM","ATR","BRCA1","BRCA2","CHEK1","CHEK2")



  #image(matrix(Freq_DfMutData[,1]), col=colorRampPalette(colors=c("#FF0000", "#FFFF00"))(length(Freq_DfMutData[,1])))

  #my.colors<-colorRampPalette(c("blue", "white","orange" ,"red")) #creates a function my.colors which interpolates n colors between blue, white and red
  #color.df<-data.frame(COLOR_VALUE=seq(-1,1,0.1), color.name=my.colors(length(seq(-1,1,0.1)))) #generates 2001 colors from the color ramp
  #reg1.with.color<-merge(reg1, color.df, by="COLOR_VALUE")


  #colnames <- colnames(df)
  #df <- as.data.frame(df)
  #df <- as.data.frame(df %>% add_rownames("Genes")) # change rownames in the first column

  # for(i in 2:length(colnames(df)) ){
  #   colname <- colnames[i]
  #   attriColorGene(df,colname, color=c(x,y,z))
  # }

  # attriColorGene <- function(df,colname, color=c(x,y,z)){
  # Max <- max(df, na.rm=TRUE)
  # Min <- min(df, na.rm=TRUE)
  # #"white","yellow", "darkgoldenrod3"
  # my.colors <- colorRampPalette(c(x,y,z)) #creates a function my.colors which interpolates n colors between blue, white and red
  # color.df <- data.frame(colname=seq(Min,Max,0.1), paste("col_", colname, sep="")=my.colors(Max- Min)) #generates 2001 colors from the color ramp
  # #df.with.color <- merge(df, color.df, by=colname)
  # #return(df.with.color)
  # }



  attriColorValue <- function(Value, df, colors=c(a,b,c, d,e)){

    #df <- df *100
    df[is.na(df)] <- 0
    if(max(df,na.rm=TRUE)<1){
      ## for Methylation df
     Min <- 0
     Max <- 1
    }else{
    df <- round(df, digits = 0)
    Max <- max(df, na.rm=TRUE)
    Min <- min(df, na.rm=TRUE)
    }
    my.colors <- colorRampPalette(colors)
    color.df<-data.frame(COLOR_VALUE=seq(Min,Max,0.1), color.name=my.colors(length(seq(Min,Max,0.1)))) #generates Max-Min colors from the color ramp
    colorRef <- color.df[which(color.df[,1]==Value),2]
    return(colorRef)
  }

  attriColorGene <- function(df){
    ## if df is for CNA levels(-2,-1,0,1,2)
    if(any(df[1,]=="-2", na.rm=TRUE)||
       any(df[1,]=="-1", na.rm=TRUE)||
       #any(df[1,]=="0", rn.rm=TRUE)||
       any(df[1,]=="1", na.rm=TRUE)||
       any(df[1,]=="2", na.rm=TRUE)
    ){

      ListFreqCNA <- apply(df, 2, function(x) as.data.frame(table(x[order(x)])))
      #names((which(ListFreqCNA$brca_tcga$ATM== max(ListFreqCNA$brca_tcga$ATM))))
      print("getting the most frequent CNA categorie...")
      dfMeansOrCNA <- as.data.frame(lapply(ListFreqCNA, function(x) x[,1][which(x[,2]== max(x[,2]))]))

      ## at this step the dfMeansOtCNA is not as numeric
      namedfMeansOrCNA <- names(dfMeansOrCNA)
      dfMeansOrCNA <- as.numeric(as.matrix(dfMeansOrCNA))
      names(dfMeansOrCNA) <- namedfMeansOrCNA
    }else{
      dfMeansOrCNA<-apply(df,2,function(x) mean(x, na.rm=TRUE))
      dfMeansOrCNA <- round(dfMeansOrCNA, digits = 0)
    }

    ## Set colors if all value are 0 set only black
     if(all(dfMeansOrCNA=="0")||all(dfMeansOrCNA=="NaN")){
       colorls <- lapply(dfMeansOrCNA, function(x) attriColorValue(x, dfMeansOrCNA, colors=c("white")))
       print("setting black color for empty data...")
     }else{
     colorls <- lapply(dfMeansOrCNA, function(x) attriColorValue(x, dfMeansOrCNA, colors=c("blue3","cyan3","white","yellow","red")))
     }
    disease_name <- unlist(lapply(strsplit(capture.output(substitute(df)), "\\$"),tail, 1))
    Children <- list(name=disease_name,unname(mapply(function(genes, color){list(list(name=genes, colour= color))},names(colorls), colorls)))
    names(Children)[2] <- "children"
    return(Children)
  }



  ## this function restructure the Diseases
  reStrDisease <- function(List){
    print("restructuring Selected Diseases...")
    circos<-lapply(List, function(x)attriColorGene(x))
    for(i in 1: length(names(circos))){
      circos[[i]]$name <- names(circos)[i]
    }
    circos <-unname(circos)
    return(circos)
  }



  ## This function restructure the Dimensions
  reStrDimension <- function(LIST){
    print("restructuring Dimensions...")
    CIRCOS <- lapply(LIST, function(x)list(name="Dimension",children=reStrDisease(x)))
    for(i in 1: length(names(CIRCOS))){
      CIRCOS[[i]]$name <- names(CIRCOS)[i]
    }
    CIRCOS <- unname(CIRCOS)
    return(CIRCOS)
  }



  #CIRCOS <- reStrDimension(r_data$ListProfData)




 ## get Wheel for Profiles Data
  output$getCoffeeWheel <- renderCoffeewheel({
    withProgress(message = 'Creating Wheel. Waiting...', value = 0.1, {
      Sys.sleep(0.25)
  ## Open graph in Browser and not in Viewer
  #options(viewer = NULL)

  getListProfData()
  #Shiny.unbindAll()
  CoffeewheelTreeProfData <- reStrDimension(r_data$ListProfData)
  #title<- paste("Profiles Data: CNA, Exp, RPPA, miRNA")
  coffeewheel(CoffeewheelTreeProfData, width=600, height=600, partitionAttribute="value") # main=title
})

})


  ## get Wheel for Methylation
  output$getCoffeeWheel_Met <- renderCoffeewheel({
    withProgress(message = 'Creating Wheel. Waiting...', value = 0.1, {
      Sys.sleep(0.25)
      ## Open graph in Browser and not in Viewer
      #options(viewer = NULL)

      #getListProfData()
      CoffeewheelTreeMetData <- reStrDimension(r_data$ListMetData)
      #title<- paste("Methylations: HM450 and HM27")
      coffeewheel(CoffeewheelTreeMetData, width=600, height=600) # main=title
    })

  })


  output$metabologram <- renderMetabologram({

    CoffeewheelTreeData <- reStrDimension(r_data$ListProfData)

    ### get Legend for static coffewheel
    #devtools::install_github("armish/metabologram")
    #library("metabologram")
    title<- paste("Wheel with selected Studies")
    metabologram(CoffeewheelTreeData, width=600, height=600, main=title, showLegend = TRUE, fontSize = 12, legendBreaks=c("NA","Min","Negative", "0", "Positive", "Max"), legendColors=c("black","blue","cyan","white","yellow","red") , legendText="Legend")


  })

  checkDimensions<- function(){

    checked_Studies <- input$StudiesIDCircos

    # get Cases for selected Studies
    CasesRefStudies <- unname(unlist(apply(as.data.frame(input$StudiesIDCircos), 1,function(x) getCaseLists(cgds,x)[1])))
    ## ger Genetics Profiles for selected Studies
    GenProfsRefStudies <- unname(unlist(apply(as.data.frame(input$StudiesIDCircos), 1,function(x) getGeneticProfiles(cgds,x)[1])))

    df <- data.frame(row.names = c("Case_CNA", "GenProf_GISTIC", "Case_mRNA", "GenProf_mRNA", "Case_Met_HM450", "GenProf_Met_HM450",
                                   "Case_Met_HM27", "GenProf_Met_HM27", "Case_RPPA", "GeneProf_RPPA", "Case_miRNA", "GenProf_miRNA",
                                   "Case_Mut","GeneProf_Mut"
                                   ) )

        for(i in 1: length(checked_Studies)){
          ### get Cases and Genetic Profiles  with cgdsr references
          GenProf_CNA<- paste(checked_Studies[i],"_gistic", sep="")
          Case_CNA   <- paste(checked_Studies[i],"_cna", sep="")

          GenProf_Exp<- paste(checked_Studies[i],"_rna_seq_v2_mrna", sep="")
          Case_Exp   <- paste(checked_Studies[i],"_rna_seq_v2_mrna", sep="")

          GenProf_Met_HM450<- paste(checked_Studies[i],"_methylation_hm450", sep="")
          Case_Met_HM450   <- paste(checked_Studies[i],"_methylation_hm450", sep="")

          GenProf_Met_HM27<- paste(checked_Studies[i],"_methylation_hm27", sep="")
          Case_Met_HM27   <- paste(checked_Studies[i],"_methylation_hm27", sep="")

          GenProf_RPPA<- paste(checked_Studies[i],"_RPPA_protein_level", sep="")
          Case_RPPA   <- paste(checked_Studies[i],"_rppa", sep="")

          GenProf_miRNA<- paste(checked_Studies[i],"_mirna", sep="")
          Case_miRNA   <- paste(checked_Studies[i],"_microrna", sep="")

          GenProf_Mut<- paste(checked_Studies[i],"_mutations", sep="")
          Case_Mut   <- paste(checked_Studies[i],"_sequenced", sep="")

          c(df,checked_Studies[i]==0)


          if(length(grep(Case_CNA, CasesRefStudies)!=0)){
            df[1,i] <- "Yes"
          }else{
            df[1,i] <- "No"
          }

           if(length(grep(GenProf_CNA, GenProfsRefStudies)!=0)){
              df[2,i] <- "Yes"
          }else{
               df[2,i] <- "No"
          }


          if(length(grep(Case_Exp, CasesRefStudies)!=0)){
            df[3,i] <- "Yes"
          }else{
            df[3,i] <- "No"
          }

          if(length(grep(GenProf_Exp, GenProfsRefStudies)!=0)){
            df[4,i] <- "Yes"
          }else{
            df[4,i] <- "No"
          }


          if(length(grep(Case_Met_HM450, CasesRefStudies)!=0)){
            df[5,i] <- "Yes"
          }else{
            df[5,i] <- "No"
          }

          if(length(grep(GenProf_Met_HM450, GenProfsRefStudies)!=0)){
            df[6,i] <- "Yes"
          }else{
            df[6,i] <- "No"
          }


          if(length(grep(Case_Met_HM27, CasesRefStudies)!=0)){
            df[7,i] <- "Yes"
          }else{
            df[7,i] <- "No"
          }

          if(length(grep(GenProf_Met_HM27, GenProfsRefStudies)!=0)){
            df[8,i] <- "Yes"
          }else{
            df[8,i] <- "No"
          }


          if(length(grep(Case_RPPA, CasesRefStudies)!=0)){
            df[9,i] <- "Yes"
          }else{
            df[9,i] <- "No"
          }

          if(length(grep(GenProf_RPPA, GenProfsRefStudies)!=0)){
            df[10,i] <- "Yes"
          }else{
            df[10,i] <- "No"
          }


          if(length(grep(Case_miRNA, CasesRefStudies)!=0)){
            df[11,i] <- "Yes"
          }else{
            df[11,i] <- "No"
          }

          if(length(grep(GenProf_miRNA, GenProfsRefStudies)!=0)){
            df[12,i] <- "Yes"
          }else{
            df[12,i] <- "No"
          }

          if(length(grep(Case_Mut, CasesRefStudies)!=0)){
            df[13,i] <- "Yes"
          }else{
            df[13,i] <- "No"
          }

          if(length(grep(GenProf_Mut, GenProfsRefStudies)!=0)){
            df[14,i] <- "Yes"
          }else{
            df[14,i] <- "No"
          }


        }
    names(df)<- checked_Studies
    return(df)
  }



    output$CircosInit <- DT::renderDataTable({


    withProgress(message = 'Loading Data...', value = 0.1, {
    Sys.sleep(0.25)


      dat <- checkDimensions()


  ## remove rownames to column
  dat <- dat %>% add_rownames("Samples")




  # action = DT::dataTableAjax(session, dat, rownames = FALSE, toJSONfun = my_dataTablesJSON)
  action = DT::dataTableAjax(session, dat, rownames = FALSE)

  DT::datatable(dat, filter = list(position = "top", clear = FALSE, plain = TRUE),
                              rownames = FALSE, style = "bootstrap", escape = FALSE,
                # class = "compact",
                options = list(
                  ajax = list(url = action),
                  search = list(regex = TRUE),
                  columnDefs = list(list(className = 'dt-center', targets = "_all")),
                  autoWidth = TRUE,
                  processing = FALSE,
                  pageLength = 14,
                  lengthMenu = list(c(10, 25, 50, -1), c('10','25','50','All'))
                )
  )%>%  formatStyle(names(dat),
                    color = styleEqual("No", 'red'))#, backgroundColor = 'white', fontWeight = 'bold'




    })
})



# expBefore <- list(HM450=list(brac_tcga=list("ATM"=0.19,"ATR"=0.02,"BRCA1"=0.02,"BRCA2"=0.89,"CHEK1"=0.71,"CHEK2"=0.03),
#                 gbm_tcga=list("ATM"=0.19,"ATR"=0.02,"BRCA1"=0.02,"BRCA2"=0.89,"CHEK1"=0.71,"CHEK2"=0.03)
#                 ),
#      HM27=list(brac_tcga=list("ATM"=0.19,"ATR"=0.02,"BRCA1"=0.02,"BRCA2"=0.89,"CHEK1"=0.71,"CHEK2"=0.03),
#                gbm_tcga=list("ATM"=0.19,"ATR"=0.02,"BRCA1"=0.02,"BRCA2"=0.89,"CHEK1"=0.71,"CHEK2"=0.03)
#      )
#      )
#
# expAfter <-list(
#   list(
#     name="HM450",
#     children=list(
#       list(name="brca_tcga",
#            children=list(
#              list(name="ATM", colour="110000"),
#              list(name="ATR", colour="330000"),
#              list(name="BRCA1", colour="550000"),
#              list(name="BRCA2", colour="770000"),
#              list(name="CHEK1", colour="990000"),
#              list(name="CHEK2", colour="bb0000")
#
#            ), colour="aa0000" # brca_tcga
#            ),
#         list(name="gbm_tcga",
#             children=list(
#               list(name="ATM", colour="001100"),
#               list(name="ATR", colour="003300"),
#               list(name="BRCA1", colour="005500"),
#               list(name="BRCA2", colour="007700"),
#               list(name="CHEK1", colour="009900"),
#               list(name="CHEK2", colour="00bb00")
#             ), colour="345345" # gbm_tcga
#             )
#
#            ), colour="ffa500" # HM450
#   ),
#   list(
#     name="HM27",
#     children=list(
#       list(name="brca_tcga",
#            children=list(
#              list(name="ATM", colour="110000"),
#              list(name="ATR", colour="330000"),
#              list(name="BRCA1", colour="550000"),
#              list(name="BRCA2", colour="770000"),
#              list(name="CHEK1", colour="990000"),
#              list(name="CHEK2", colour="bb0000")
#
#            ), colour="aa0000" ##brca_tcga
#            ),
#       list(name="gbm_tcga",
#            children=list(
#              list(name="ATM", colour="001100"),
#              list(name="ATR", colour="003300"),
#              list(name="BRCA1", colour="005500"),
#              list(name="BRCA2", colour="007700"),
#              list(name="CHEK1", colour="009900"),
#              list(name="CHEK2", colour="00bb00")
#            ), colour="345345") #gbm_tcga
#
#     ), colour="ff00ff"  #HM27
#   )
#
# );
# library("coffeewheel")
# coffeewheel(expAfter, width=500, height=500, main="Sample Wheel Title", partitionAttribute="value")
