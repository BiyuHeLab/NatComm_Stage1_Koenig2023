% calls MVPA using The Decoding Toolbox, on GLM outputs from HLTP fMRI task
% make edits to below parameters for a particular decoding analysis
% finally calls HLTP_runDecoding.m, which in turn calls TDT functions

allsubs = {'P6','P7','P8','P12','P13','P14'};
rois = {'sfc','ofc','mpfc','vlpfc','dlpfc','loci','locs','evc','tof'};
data_dir = '~PATH_TO_DATA_DIR'; % PATH TO MAIN DATA DIRECTORY
decodingDir = '../toolboxes/decoding_toolbox_v3.991';
addpath(decodingDir)
nImages = 10;
nROIs = length(rois);
repeats = 100;
AllTrialsBlocks = kron([1:15],ones(1,50));   
AllTrialCopeIDs = repmat([1:50],1,15);
    
for sub = 1:length(allsubs)
    subdir = [allsubs{sub} '/']; % PATH TO SUBJECT'S DATA DIRECTORY
    fid = fileread([subdir 'GLMsingletrial_conditions.txt']);
    fid = strrep(fid, 'NA', '');
    AllConds = textscan(fid, '%f%f%f%f%f%f', 'CollectOutput', true, 'Delimiter', ' ', 'EmptyValue',nan, 'HeaderLines',1);
    AllConds = AllConds{:}; %Column names: "retro_0_post_1" "image_cued" "accuracy" "response" "missing_img1" "missing_img2"
    
    %% REQUIRED PARAMETERS
    resultsdir = [subdir 'mvpa/roi_betas_WMplus_singletrial_missingpostcorr_AllData_weightedtraining_SVM_CorrectST/'];
    betasdir1 = 'GLMsingletrial.feat'; % .feat directory to pull COPEs from
    anatROIFolder = [subdir 'rois/'];

    parfor repeat = 1:repeats
        class1imgs = {};
        class2imgs = {};

        conds = AllConds;
        for img = 0:9
           class1 = find((conds(:,1) == 1) & (conds(:,2) == img) & (conds(:,3) == 1));
           if img < 5
               class2 = find((conds(:,1) == 1) & (conds(:,5) == img & (conds(:,3) == 1)));
           else
               class2 = find((conds(:,1) == 1) & (conds(:,6) == img & (conds(:,3) == 1)));
           end
           class1imgs{img+1} = class1;
           class2imgs{img+1} = class2;
        end

        %% INITIALIZE

        for iImage = 0:9 %Run decoding for each ROI and each image separately, then average results across images within each ROI\
            for iROI = 1:nROIs
                run_and_save_decoding_alldata_SVM(sub, subdir, resultsdir, repeat, iROI, iImage, class1imgs, class2imgs, AllTrialsBlocks, AllTrialCopeIDs, rois, allsubs, betasdir1);
            end
        end
    end
end

%% Permutation test
for sub=1:length(allsubs)
    for rep = 1:repeats
        for iROI = 1:nROIs
            for iImage = 0:9
                combine=0;
                ROIname = rois{iROI};
                ThisResultsDir = fullfile(allsubs{sub}, 'mvpa', 'roi_betas_WMplus_singletrial_missingpostcorr_AllData_weightedtraining_SVM_CorrectST', ['image' num2str(iImage)], ROIname, ['rep' num2str(rep)]);
                cfg_file = [ThisResultsDir, '/res_cfg.mat'];
                output = {'balanced_accuracy','confusion_matrix'};
                Temp2A_run_permutation_10perms(ThisResultsDir, output, combine);
            end
        end
    end
end

% %% Average decoding accuracies across images within each ROI for each subject
average_balanced_accuracy = zeros(length(allsubs),nImages,nROIs,repeats);
for repeat=1:repeats
    for sub=1:length(allsubs)
        for iImage = 0:9 %Run decoding for each ROI and each image separately, then average results across images within each ROI\
            for iROI = 1:nROIs
               balanced_acc = load([allsubs{sub}, '/', 'mvpa/roi_betas_WMplus_singletrial_missingpostcorr_AllData_weightedtraining_SVM_CorrectST/image', num2str(iImage), '/', rois{iROI}, '/rep', num2str(repeat),'/res_balanced_accuracy.mat']);
               average_balanced_accuracy(sub,iImage+1,iROI,repeat) = balanced_acc.results.balanced_accuracy.output;
            end
        end
    end
end

mean_accuracy_persub_perroi = squeeze(mean(squeeze(mean(average_balanced_accuracy,2)),3));

% %% Assess results of permutation
% % Take 5000 balanced accuracies per subject per ROI
nReps = 5000;
nullDistribAll = zeros(5000,nROIs,3);
pvalues = zeros(3,nROIs);
permchance = zeros(3,nROIs);

for sub = 1:3
    for iROI = 1:nROIs
        ROIname = rois{iROI};
        parfor i = 1:nReps
            if mod(i,100) == 0
                disp(['Currently on subject ', num2str(sub), ', ROI #', num2str(iROI), ', rep # ', num2str(i)]);
            end
            randselection = randsample(10,10,true); %with replacement
            randomsamples = zeros(100,10); %across repeats and images
            for repeat = 1:100
                for iImage = 0:9    
                    accuracy = load([allsubs{sub} '/mvpa/roi_betas_WMplus_singletrial_missingpostcorr_AllData_weightedtraining_SVM_CorrectST/image' num2str(iImage) '/' ROIname '/rep' num2str(repeat) '/perm/perm' num2str(randselection(iImage+1),'%04.f') '_balanced_accuracy.mat']);
                    randomsamples(repeat,iImage+1) = accuracy.results.balanced_accuracy.output;
                end
            end
            nullDistribAll(i,iROI,sub) = mean(mean(randomsamples));
        end
        pvalues(sub,iROI) = sum(nullDistribAll(:,iROI,sub) >= mean_accuracy_persub_perroi(sub,iROI)) / nReps;
        permchance(sub,iROI) = median(nullDistribAll(:,iROI,sub));
    end
end

results = struct('mean',{mean_accuracy_persub_perroi},'pvalues',{pvalues},'permchance',{permchance});
save('balacc_beta_main_singletrial_n=6.mat','results');

