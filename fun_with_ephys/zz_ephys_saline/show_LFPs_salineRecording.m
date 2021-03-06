% This script shows the LFP band recorded using a saline solution, withou any
% changes from our first attempt at recording from a bat. I just wanna check if
% I spot the same noise and the same patterns I observe in the real recordings
%
% This is a wrapper script, for simplicity. Since I'll be showing for
% different cases:
%     i. my own channel mapping with the imfor
%     ii. channel mapping using a long column, from the SpikeGLX docs
%     iii. channel mapping with tetrodes, from the SpikeGLX docs

clc;
clear all;


% prepare and load some basic shit
addpath( 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\helper_fcns\' );
% define where the data is.... (this is my particular ordering, tho)
datapath_matvars = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\';

%% i. shown saline with my own imro map

rootLFPfiles = 'E:\Francisco\Neuropixels_Prelim\SalineRecordings\NoiseTest_211014\MyImroChannels_ExtRef\FullShank_SalineTest_211410_g0\FullShank_SalineTest_211410_g0_imec0';
lfp_filename = 'FullShank_SalineTest_211410_g0_t0.imec0.lf.bin';

fullpath_chanmap = [datapath_matvars, 'FullShank_SalineTest_ap_kilosortChanMap.mat'];

work_shownSalineNpixels( rootLFPfiles, lfp_filename, fullpath_chanmap, [23 26], 1000 );

%% ii. show saline with the spike GLX doc long column
% column only spans banks 0 and 1...

rootLFPfiles = 'E:\Francisco\Neuropixels_Prelim\SalineRecordings\NoiseTest_211014\ImroMaps_SpikeGLXdocs\LongColMaps_3b_SpikeGLXsDoc_g0\LongColMaps_3b_SpikeGLXsDoc_g0_imec0';
lfp_filename = 'LongColMaps_3b_SpikeGLXsDoc_g0_t0.imec0.lf.bin';

fullpath_chanmap = [datapath_matvars, 'LongColMaps_3b_SpikeGLXsDoc_g0_t0.imec0.ap_kilosortChanMap.mat'];

work_shownSalineNpixels( rootLFPfiles, lfp_filename, fullpath_chanmap, [23 26], 2000 );

%% iii. show saline with the spiek GLX map of tetrodes..
% again only banks 0 and 1, but here makes more sense...

rootLFPfiles = 'E:\Francisco\Neuropixels_Prelim\SalineRecordings\NoiseTest_211014\ImroMaps_SpikeGLXdocs\Tetrode_3B_SpikeGLXsDoc_g0\Tetrode_3B_SpikeGLXsDoc_g0_imec0';
lfp_filename = 'Tetrode_3B_SpikeGLXsDoc_g0_t0.imec0.lf.bin';

fullpath_chanmap = [datapath_matvars, 'Tetrode_3B_SpikeGLXsDoc_g0_t0.imec0.ap_kilosortChanMap.mat'];

work_shownSalineNpixels( rootLFPfiles, lfp_filename, fullpath_chanmap, [23 26], 3000 );