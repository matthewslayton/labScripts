library(dplyr)
library(ggplot2)
library(effects)
library(readxl)
library(openxlsx)
library(lmerTest)
library(R.matlab)
library(sjPlot)

# PCs
#tbl <- read_excel('Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivityROI_step1avg_PC.xlsx', sheet = 'pogL')
tbl <- read_excel('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivity_CleanCustomROIs_PC_F500.xlsx', sheet = 'R_Fus_PC')
# mask28_PC, 29, 30, 31, 32, 34, 35, 37, 39, 40, 41
# L_HC_PC, R_HC, L_PhG, R_PhG, L_Fus, R_Fus

# make sure model knows the itemIDs are strings, not numbers
tbl$ItemID <- factor(tbl$ItemID)

# one big model
#model = lmer(AvgROI~PC01+PC02+PC03+PC04+PC05+PC06+PC07+PC08+PC09+PC10+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model)

# need the full summary to see the t-values
summary(model)

# ten indiv models
model1 = lmer(AvgROI~PC01+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model1)

model2 = lmer(AvgROI~PC02+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model2)

model3 = lmer(AvgROI~PC03+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model3)

model4 = lmer(AvgROI~PC04+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model4)

model5 = lmer(AvgROI~PC05+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model5)

model6 = lmer(AvgROI~PC06+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model6)

model7 = lmer(AvgROI~PC07+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model7)

model8 = lmer(AvgROI~PC08+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model8)

model9 = lmer(AvgROI~PC09+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model9)

model10 = lmer(AvgROI~PC10+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model10)

# Factors
#tbl <- read_excel('Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivityROI_step1avg_F.xlsx', sheet = 'pogL')
#tbl <- read_excel('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivity_customROIs_PC_F.xlsx', sheet = 'mask41_F')
tbl <- read_excel('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivity_CleanCustomROIs_PC_F500.xlsx', sheet = 'R_Fus_F')
# mask28_F, 29, 30, 31, 32, 34, 35, 37, 39, 40, 41
# L_HC_F, R_HC, L_PhG, R_PhG, L_Fus, R_Fus

# make sure model knows the itemIDs are strings, not numbers
tbl$ItemID <- factor(tbl$ItemID)

# one big model
#model = lmer(AvgROI~F01+F02+F03+F04+F05+F06+F07+F08+F09+F10+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model)

# need the full summary to see the t-values
#summary(model)

# ten indiv models
model1 = lmer(AvgROI~F01+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model1)
summary(model1)

model2 = lmer(AvgROI~F02+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model2)
summary(model2)

model3 = lmer(AvgROI~F03+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model3)
summary(model3)

model4 = lmer(AvgROI~F04+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model4)
summary(model4)

model5 = lmer(AvgROI~F05+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model5)
summary(model5)

model6 = lmer(AvgROI~F06+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model6)
summary(model6)

model7 = lmer(AvgROI~F07+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model7)
summary(model7)

model8 = lmer(AvgROI~F08+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model8)
summary(model8)

model9 = lmer(AvgROI~F09+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model9)
summary(model9)

model10 = lmer(AvgROI~F10+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model10)
summary(model10)


#plot_model(model)
#summary(model)

# mem
tbl <- read_excel('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/avgActivity_customROIs_mem.xlsx', sheet = 'R_Fus_mem')
# mask28_mem, 29, 30, 31, 32, 34, 35, 37, 39, 40, 41
# L_HC_mem, R_HC, L_PhG, R_PhG, L_Fus, R_Fus

# make sure model knows the itemIDs are strings, not numbers
tbl$ItemID <- factor(tbl$ItemID)

# one big model
model = lmer(AvgROI~lexMem+visMem+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model)
# need the full summary to see the t-values
summary(model)

# ten indiv models
model1 = lmer(AvgROI~lexMem+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model1)
summary(model1)

model2 = lmer(AvgROI~visMem+(1|Subj)+(1|ItemID),data=tbl)
sjPlot::tab_model(model2)
summary(model2)


# bothMem

tbl <- read_excel('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/activity_mem_only.xlsx', sheet = 'R_Fus')
# mask28, 29, 30, 31, 32, 34, 35, 37, 39, 40, 41, L_HC, R_HC, L_PhG, R_PhG, L_Fus, R_Fus

# make sure model knows the itemIDs are strings, not numbers
tbl$ItemID <- factor(tbl$ItemID)

# model
model = lmer(AvgROI~bothMem+(1|Subj)+(1|ItemID),data=tbl)
#sjPlot::tab_model(model)
# need the full summary to see the t-values
summary(model)


#########
## cmem/mturk_lexMem and pmem/mturk_visMem

tbl <- read_excel('/Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/mturk_cmem_pmem_activity.xlsx',sheet = 'Sheet17')

# use Sheet1, Sheet2, ... , Sheet17
# mask28, mask29, mask30 [etc], 31, 32, 34, 35, 37, 39, 40, 41, fugL, fugR, hippL, hippR, phgL, phgR

# mturk_cmem_pmem_activity_full.xlsx  has the NaNs
# mturk_cmem_pmem_activity.xlsx does not

# make sure model knows the itemIDs are strings, not numbers
tbl$itemID <- factor(tbl$itemID)


# model
model_cmem = lmer(AvgROI~lexMem+cmem+(1|Subj)+(1|itemID),data=tbl)
#sjPlot::tab_model(model)
# need the full summary to see the t-values
summary(model_cmem)

model_pmem = lmer(AvgROI~visMem+pmem+(1|Subj)+(1|itemID),data=tbl)
summary(model_pmem)








#Positive
model = lmer(PCL_R_2_1~y_HvM*mem_state*+(1|Subject)+(1|Stimulus),data=tbl,REML = TRUE )
plot_model(model, type = "pred", terms = c("mem_state","y_HvM"))