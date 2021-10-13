% This script holds the code to visualize vocalization, both single ones,
% isolated, and full traces in a file... have fun
% 02 oct. 2020.. modified 7.7.2021

clc;
clear all;

% prepare and load some basic shit
% addpath( 'D:\Work\Papers\9_BuildUpFAF_AC_Striatum_Data\___helper_functions' );
% define where the data is.... (this is my particular ordering, tho)
rootwavfiles = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_matvars = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\'
mapping_file = 'DataArrangement_dummy.xlsx';
rootLFPfiles = 'D:\Data\_____FAF_AC_A16x2_voc\processed_resampled_lfps\vocs\';

load( [datapath_matvars, 'vocs_condensed_data.mat'] );
T = readtable( [ datapath_matvars, 'DataArrangement_dummy.xlsx' ] );
   
% take vocalization number, and show it. nice vocalizations I have marked
% in the excel vocalization file... work with that
% now, extract some important stuff
vocnum = 1; % 552 seems like a perfect non-echo; -> used
              % 131 seems like a very good echo;
              % 611 is perfect echo -> used

voccol = vocs_condensed_struct(vocnum).colID;
vocstart = vocs_condensed_struct(vocnum).voc_start;
vocend = vocs_condensed_struct(vocnum).voc_end;
wavname = vocs_condensed_struct(vocnum).file;

% show a large ( +- 5s?) segment where this voc is found
% figure out which file it is
fullwav_filename = [ rootwavfiles, wavname ];

% load the wav file, and get the segment where the vocalization is
[ wavnow, fs_voc ] = audioread( fullwav_filename );
tfull = [ 0 : numel( wavnow ) - 1 ] ./ fs_voc;
[ off_left, off_right ] = deal( [ 4e-3 * fs_voc, 4e-3 * fs_voc ] );
wavseg = wavnow( vocstart - off_left + 1 : vocend + off_right - 1 );
tseg = tfull( vocstart - off_left + 1 : vocend + off_right - 1 );
figure(vocnum); clf;
plot( tseg, wavseg ); axis tight;
hold on; plot( tfull( vocstart : vocend ), wavnow( vocstart : vocend ), 'r' );

