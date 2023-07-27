#Script to analyze piloting data for Templeton Exp 2A fMRI pilot
## Script started on March 30, 2023, with new design thought up in response to the first round of reviews received from NHB

setwd("/isilon/LFMI/VMdrive/Lua/Temp2A/Temp2A_fMRI_pilot")
subs = c("P6","P7","P8","P12","P13","P14")
same="6"
diff="7"

allimages = seq(0,9)

for (sub in 1:length(subs)) {
  #Read in the data with the subject number in its file name
  subject_code = subs[sub]

  if (sub == 1){
    part1 = read.csv("./Main Task/behav_data/P6_TC_templeton_exp2A_fMRI_SD67_2022_Jan_13_1119.csv")[-c(1:3,501),-c(2:27,32:99)]
    part2 = read.csv("./Main Task/behav_data/P6_TC_2_templeton_exp2A_fMRI_SD67_2022_Jan_13_1249.csv")[-c(1:3),-c(2:27,32:99)]
    behavdat = rbind(part1,part2)
    rm(part1,part2)
    part1 = read.table("./Main Task/behav_data/P6_TC_templeton_exp2A_fMRI_SD67_2022_Jan_13_1119.log",sep="\t",fill=T)
    mainTaskStart = which(part1$V3 == "static_instruction_33: autoDraw = True")
    part1 = part1[-(1:mainTaskStart),]
    part2 = read.table("./Main Task/behav_data/P6_TC_2_templeton_exp2A_fMRI_SD67_2022_Jan_13_1249.log",sep="\t",fill=T)
    mainTaskStart = which(part2$V3 == "static_instruction_33: autoDraw = True")
    part2 = part2[-(1:mainTaskStart),]
    logdat = rbind(part1,part2)
    rm(part1,part2)
    maintaskruns = c("10","11","12","13","14","15","16","19","20","21","22","23","24","25","26")
  } else if (sub == 2) {
    behavdat = read.csv(dir('./Main Task/behav_data', full.names=T, pattern=paste0("^",as.character(subject_code)))[1])[-c(1:3),-c(2:27,32:99)]
    logdat = read.table("./Main Task/behav_data/P7_HM_templeton_exp2A_fMRI_SD67_2022_Jan_14_1108.log",sep='\t',fill=T)
    mainTaskStart = which(logdat$V3 == "static_instruction_33: autoDraw = True")
    logdat = logdat[-(1:mainTaskStart),]
    maintaskruns = c("09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
  } else if (sub == 3) {
    behavdat = read.csv(dir('./Main Task/behav_data', full.names=T, pattern=paste0("^",as.character(subject_code)))[1])[-c(1:9),-c(2:27,32:99)]
    logdat = read.table("./Main Task/behav_data/P8_SC_templeton_exp2A_fMRI_SD67_2022_Jan_25_1937.log",sep="\t",fill=T)
    mainTaskStart = which(logdat$V3 == "static_instruction_33: autoDraw = True")
    logdat = logdat[-(1:mainTaskStart),]
    maintaskruns = c("11","12","13","14","15","16","17","18","19","20","21","22","23","24","25")
  } else if (sub == 4){
    behavdat = read.csv("./Main Task/behav_data/P12_templeton_exp2A_fMRI_SD67_2023_Jul_05_1646.csv")[-c(1:9,760),-c(2:27,32:99)]
    logdat = read.table('./Main Task/behav_data/P12_templeton_exp2A_fMRI_SD67_2023_Jul_05_1646.log',sep='\t',fill=T)
    mainTaskStart = which(logdat$V3 == "static_instruction_33: autoDraw = True")
    logdat = logdat[-(1:mainTaskStart),]
    maintaskruns = c("09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
  } else if (sub == 5) {
    behavdat = read.csv(dir('./Main Task/behav_data', full.names=T, pattern=paste0("^",as.character(subject_code)))[1])[-c(1:9,760),-c(2:27,32:99)]
    logdat = read.table("./Main Task/behav_data/P13_templeton_exp2A_fMRI_SD67_2023_Jul_06_1544.log",sep='\t',fill=T)
    mainTaskStart = which(logdat$V3 == "static_instruction_33: autoDraw = True")
    logdat = logdat[-(1:mainTaskStart),]
    maintaskruns = c("08","09","10","11","12","13","14","15","16","17","18","19","20","21","22")
  } else {
    behavdat = read.csv(dir('./Main Task/behav_data', full.names=T, pattern=paste0("^",as.character(subject_code)))[1])[-c(1:9),-c(2:27,32:99)]
    logdat = read.table("./Main Task/behav_data/P14_AB_templeton_exp2A_fMRI_SD67_2023_Jul_14_1224.log",sep="\t",fill=T)
    mainTaskStart = which(logdat$V3 == "static_instruction_33: autoDraw = True")
    logdat = logdat[-(1:mainTaskStart),]
    maintaskruns = c("09","10","11","12","13","14","15","16","17","18","19","20","21","22","23")
  }
  
  start_times_memoryarray = round(behavdat$array_image_1h.started*10)/10
  start_times_testarray = round(behavdat$array_image_1j.started*10)/10
  start_times_cue = round(behavdat$pointer_dot_0c.started*10)/10
  memory_retint_duration = rep(0.5,length(start_times_testarray))
  test_response_duration = round(behavdat$sd_resp_real.rt*10)/10 #this lasts from the onset of the test array (response period) until the onset of the confidence response period
  test_response_duration[which(behavdat$retro_0_post_1_real == 1)] = test_response_duration[which(behavdat$retro_0_post_1_real == 1)] + 0.1 #response RTs start at cue-onset in post-cue trials which happens 0.1 s after the onset of the test array; we want to model from when the test array appears
  test_response_duration[which(behavdat$retro_0_post_1_real == 0)] = test_response_duration[which(behavdat$retro_0_post_1_real == 0)] + 1.3 #response RTs start at test-onset in retro-cue trials which happens 1300 ms after the cue; we want to model from when the cue appears
  starts_durations = cbind(start_times_memoryarray,start_times_testarray,start_times_cue,memory_retint_duration,test_response_duration)
  colnames(starts_durations) = c("start_memory","start_test","start_cue","duration_postmemory","duration_posttest")
  
  #Log accuracy for each trial
  behavdat[which((behavdat$change_or_no_real==0)&(behavdat$sd_resp_real.keys==same)),"accuracy"] = 1
  behavdat[which((behavdat$change_or_no_real==1)&(behavdat$sd_resp_real.keys==diff)),"accuracy"] = 1
  behavdat[which((behavdat$change_or_no_real==0)&(behavdat$sd_resp_real.keys==diff)),"accuracy"] = 0
  behavdat[which((behavdat$change_or_no_real==1)&(behavdat$sd_resp_real.keys==same)),"accuracy"] = 0
  
  #Log which image was cued and which images are missing from memory array
  missing_imgs = array(NA,c(nrow(behavdat),2))
  for (i in 1:nrow(behavdat)){
    images_in_memory_array = behavdat[i,14:21]
    if (!is.na(behavdat[i,"cue_location_real"])){
      behavdat[i,"image_cued"] = images_in_memory_array[behavdat[i,"cue_location_real"]+1]
    } else {
      behavdat[i,"image_cued"] = NA
    }
    if (!is.na(images_in_memory_array[1])){
      missing_imgs[i,] = allimages[!allimages %in% images_in_memory_array]
    }
  }
  
  #Log which trials had no response
  behavdat[which(behavdat$sd_resp_real.keys == "None"),"response"] = 0
  behavdat[which(behavdat$sd_resp_real.keys != "None"),"response"] = 1
  
  n_block = 15
  n_trial = 50
  TR_length = 1.5
  
  Master_Conds = cbind(behavdat$retro_0_post_1_real,behavdat$image_cued,behavdat$accuracy,behavdat$response,missing_imgs)
  colnames(Master_Conds) = c("retro_0_post_1","image_cued","accuracy","response","missing_img1","missing_img2")
  write.table(Master_Conds,paste0("./proc_data/",subs[sub],"/GLMsingletrial_conditions.txt"),row.names = F)

  for (block in 1:n_block){
    blockdat = behavdat[((block-1)*n_trial + 1):((block-1)*n_trial + n_trial),]
    starts_durations_block = as.data.frame(starts_durations[((block-1)*n_trial + 1):((block-1)*n_trial + n_trial),])
    starts_durations_block[,3] = starts_durations_block[,3] - starts_durations_block[1,1] #make all start times relative to the start of the run
    starts_durations_block[,2] = starts_durations_block[,2] - starts_durations_block[1,1] #make all start times relative to the start of the run
    starts_durations_block[,1] = starts_durations_block[,1] - starts_durations_block[1,1] #make all start times relative to the start of the run
    blockdat = blockdat[,c("retro_0_post_1_real")]
    
    ### FOR GLM ###
    # Need one regressor per trial
    # + 1 regressor for onset of test array in all post-cue trials (retro_0_post_1_real = 1)
    # + 1 regressor for onset of testa array in all retro-cue trials (retro_0_post_1_real = 0)
    # = Total of 52 regressors
    
    #Test-array regressor
    allpostcue = which(blockdat == 1)
    reg_test = cbind(starts_durations_block$start_test,starts_durations_block$duration_posttest) 
    reg_test = cbind(reg_test,0)
    reg_test[allpostcue,3] = 1
    write.table(round(reg_test,2),paste0("./proc_data/",subs[sub],"/EVfiles/GLMsingletrial_run",maintaskruns[block],"_testarraypostcue.txt"),col.names = F,row.names = F)
    
    allretrocue = which(blockdat == 0)
    reg_test_r = cbind(starts_durations_block$start_cue,starts_durations_block$duration_posttest) 
    reg_test_r = cbind(reg_test_r,0)
    reg_test_r[allretrocue,3] = 1
    write.table(round(reg_test_r,2),paste0("./proc_data/",subs[sub],"/EVfiles/GLMsingletrial_run",maintaskruns[block],"_testarrayretrocue.txt"),col.names = F,row.names = F)
    
    for (trial in 1:50){
      regtrial = cbind(starts_durations_block$start_memory,starts_durations_block$duration_postmemory,0)
      regtrial[trial,3] = 1
      write.table(round(regtrial,2),paste0("./proc_data/",subs[sub],"/EVfiles/GLMsingletrial_run",maintaskruns[block],"_trial",trial,".txt"),col.names = F,row.names = F)
    }
  }
}
