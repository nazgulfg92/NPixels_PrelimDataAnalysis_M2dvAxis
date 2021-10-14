% Script uses https://djoshea.github.io/neuropixel-utils/ to load and visualize lf data.
% I'm gonna compare if what I can get from here is similar to what I see
% when I read the data myself

clc;
clear all;

% prepare and load some basic shit
addpath( 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\helper_fcns\' );
% define where the data is.... (this is my particular ordering, tho)
rootwavfiles = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_matvars = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\';
mapping_file = 'DataArrangement_dummy.xlsx';
rootLFPfiles = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
lfp_filename = 'M2-DVAxis-210922-210922_g9_t0.imec0.lf.bin';
spk_filename = 'M2-DVAxis-210922-210922_g9_t0.imec0.ap.bin';

load( [datapath_matvars, 'vocs_condensed_data.mat'] );
% load( [datapath_matvars, 'M2-DVAxis-210922-210922_g1_t0.imec0.ap_kilosortChanMap.mat'] );


%% dealing with spike data
clc;

imec = Neuropixel.ImecDataset( [rootLFPfiles, spk_filename], ...
                'channelMap', 'M2-DVAxis-210922-210922_g1_t0.imec0.ap_kilosortChanMap.mat' );
            
% Mark individual channels as bad based on RMS voltage
rmsBadChannels = imec.markBadChannelsByRMS('rmsRange', [3 75]);

% Specify names for the individual bits in the sync channel
imec.setSyncBitNames([1 2 3], {'trialInfo', 'trialStart', 'stim'});

% % Perform common average referencing on the file and save the results to a new location
% cleanedPath = '/data/cleaned_datasets/neuropixel_01.imec.lf.bin';
% extraMeta = struct();
% extraMeta.commonAverageReferenced = true;
% fnList = {@Neuropixel.DataProcessFn.commonAverageReference};
% imec = imec.saveTransformedDataset(cleanedPath, 'transformLF', fnList, 'extraMeta', extraMeta);

% Sym link the cleaned dataset into a separate directory for Kilosort2
% ksPath = '/data/kilosort/neuropixel_01.imec.ap.bin';
% imec = imec.symLinkAPIntoDirectory(ksPath);

% Inspect the raw IMEC traces
imec.inspectLF_timeWindow([10 50]); % 200-201 seconds into the recording
