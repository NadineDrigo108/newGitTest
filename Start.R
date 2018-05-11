dati_wd = "/whrc/biomass/ndrigo/dati"
setwd(dati_wd)

getwd()

library(rgdal)
library(raster)
library(sp)


###read raster scene from L5 169060 year 2008
#folders names
J01 = "LT051690602008060101T1-SC20180509120607"
S05 = "LT051690602008090501T1-SC20180509120647"
S21 = "LT051690602008092101T1-SC20180509120522"

#fmask
mask = "_pixel_qa.tif"

#----------------JUNE 01 2008--------------------------
#set wd in the Landsat image I am interested in
setwd(paste0(dati_wd, "/", J01))

#list files to put in the stack (bands 1 to 7)
lf = list.files(path = "/whrc/biomass/ndrigo/dati/LT051690602008060101T1-SC20180509120607", 
           pattern ="band"  )
mask = list.files(path = ".", pattern = "pixel")
#create a stack
J01stack = stack(paste0("/whrc/biomass/ndrigo/dati/LT051690602008060101T1-SC20180509120607/", lf))

#general info about the stack or raster
J01stack

#visualise one band of the stack
plot(J01stack, 1)

#select 
J01mask = raster(mask)

#reclassify the raster based on the values: to do so i need a matrix with 3 colums:
# 1) from, 2) to, 3) becomes. this can be done by a vector that can be transformed 
#in matrix with byrow=TRUE

#matrix for clouds Clouds and shadows = 2
recMatC = matrix(c(72,2,136,2,96,2,112,2,160,2,176,2,224,2), ncol = 2, byrow = T)
recMatC

#matrix for other: all other codes = 0
recMatO = matrix(c(3,255,0), ncol = 3, byrow = T)
recMatO

# maskC2 = reclassify(J01mask, rcl = recMatC)
# maskJ01 = reclassify(maskC2, rcl = recMatO)

maskJ01 = reclassify(reclassify(J01mask, rcl = recMatC), rcl = recMatO)
maskJ01
plot(maskJ01)

CleanJ01 = mask(J01stack, maskJ01, filename = "J01Clean", maskvalue = 2)
plot(CleanJ01,1)

writeRaster(CleanJ01,"ClenaTest", "GTiff")

#-------------------SEPTEMBER 05 2008--------------
#set wd in the Landsat image I am interested in
S05path = paste0(dati_wd, "/", S05)
setwd(S05path)

#list files to put in the stack (bands 1 to 7)
lf = list.files(path = S05path, pattern ="band")
lf = list.files(path = ".", pattern ="band")
mask = list.files(path = ".", pattern = "pixel")
#create a stack
S05stack = stack(paste0(S05path, "/", lf))


#select 
S05mask = raster(mask)

#reclassify the raster based on the values: to do so i need a matrix with 3 colums:
# 1) from, 2) to, 3) becomes. this can be done by a vector that can be transformed 
#in matrix with byrow=TRUE

#matrix for clouds Clouds and shadows = 2
recMatC = matrix(c(72,2,136,2,96,2,112,2,160,2,176,2,224,2), ncol = 2, byrow = T)
recMatC

#matrix for other: all other codes = 0
recMatO = matrix(c(3,255,0), ncol = 3, byrow = T)
recMatO

# maskC2 = reclassify(J01mask, rcl = recMatC)
# maskJ01 = reclassify(maskC2, rcl = recMatO)

maskS05 = reclassify(reclassify(S05mask, rcl = recMatC), rcl = recMatO)
maskS05
plot(maskS05)

CleanS05 = mask(S05stack, maskS05, filename = "S05Clean.tif", maskvalue = 2)
CleanS05 = mask(S05stack, maskS05, maskvalue = 2)
plot(CleanS05,1)
plot(CleanS05,4)


#~~~~~~~~~~        MY LOVELY FUNCTION           ~~~~~~~~~~~~~~
MaskCloud = function(folder){
  dati_wd = "/whrc/biomass/ndrigo/dati"
  setwd(dati_wd)
  image_dir = paste0(getwd(),"/", folder)
  setwd(image_dir)
  lf = list.files(path = ".", pattern = "band")
  #lf[-1]
  mf = list.files(path = ".", patter = "pixel")
  image_stack = stack(paste0(image_dir, "/", lf))
  image_mask_f = raster(mf)
  RecMatC = matrix(c(72,NA,136,NA,96,NA,112,NA,160,NA,176,NA,224,NA), ncol = 2, byrow = T)
  RecMatO = matrix(c(3,255,0), ncol = 3, byrow = T)
  image_mask = reclassify(reclassify(image_mask_f, rcl = RecMatC), rcl = RecMatO)
  name = substr(lf[1],1,44)
  clean_image_name = paste0(name, "CloudFreeStack.tif")
  clean_image = mask(image_stack, image_mask, maskvalue = 2, updatevalue=NA, overwrite = TRUE)
  writeRaster(clean_image,filename = clean_image_name, "GTiff", overwtire = T)
}

#.................DEBUG..............
dati_wd = "/whrc/biomass/ndrigo/dati"
setwd(dati_wd)
image_dir = paste0(getwd(),"/", J01)
setwd(image_dir)
lf = list.files(path = ".", pattern = "band")
#lf[-1]
mf = list.files(path = ".", patter = "pixel")
image_stack = stack(paste0(image_dir, "/", lf))
image_mask_f = raster(mf)
RecMatC = matrix(c(72,NA,136,NA,96,NA,112,NA,160,NA,176,NA,224,NA), ncol = 2, byrow = T)
RecMatO = matrix(c(3,255,0), ncol = 3, byrow = T)
image_mask = reclassify(reclassify(image_mask_f, rcl = RecMatC), rcl = RecMatO)
name = substr(lf[1],1,44)
clean_image_name = paste0(name, "CloudFreeStack.tif")
clean_image = mask(image_stack, image_mask, maskvalue = 2, updatevalue=NA, overwrite = TRUE)
writeRaster(clean_image,filename = clean_image_name, "GTiff", overwtire = T)

#~~~~~~~~~~~~~~~~   RUN THE LOVELY FUNCTION ~~~~~~~~~~~~~
# LANDSAT scenes folders name
J01 = "LT051690602008060101T1-SC20180509120607"
S05 = "LT051690602008090501T1-SC20180509120647"
S21 = "LT051690602008092101T1-SC20180509120522"
MaskCloud(J01)
MaskCloud(S05)
MaskCloud(S21)

#output check
setwd(J01)
J01stack_check <- stack("LT05_L1TP_169060_20080601_20161031_01_T1_sr_CloudFreeStack.tif")
setwd(dati_wd)
setwd(S05)
S05Stack_check = stack("LT05_L1TP_169060_20080905_20161029_01_T1_sr_CloudFreeStack.tif")
setwd(dati_wd)
setwd(S21)
S21Stack_check = stack("LT05_L1TP_169060_20080921_20161029_01_T1_sr_CloudFreeStack.tif")

L52008 = merge(J01stack_check,S05Stack_check,S21Stack_check)
J01stack_check
S05Stack_check
S21Stack_check

#find the smallest extent:
ExtentSurface = function(myraster) {
  b = myraster@extent@xmax - myraster@extent@xmin
  h = myraster@extent@ymax + myraster@extent@ymin
  A = b*h
  return(A)
}

ExtentSurface(J01stack_check)
ExtentSurface(S05Stack_check)
ExtentSurface(S21Stack_check)

smallestExtent = extent(S05Stack_check)
newJ01 = crop(J01stack_check, extent(S05Stack_check))
newS21 = crop(S21Stack_check, extent(S05Stack_check))










