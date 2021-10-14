
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

%%
clc;

imec = Neuropixel.ImecDataset( [rootLFPfiles, spk_filename], ...
                'channelMap', 'M2-DVAxis-210922-210922_g1_t0.imec0.ap_kilosortChanMap.mat' );