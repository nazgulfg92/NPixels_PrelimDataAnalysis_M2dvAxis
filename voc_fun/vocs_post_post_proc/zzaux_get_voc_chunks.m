% This script gets me the vocalization chunks into a variable. This way,
% if I wanna check the chunks, I never have to load a full wav file
%     
% Written: 07 july 2021
% 

clc;
clear all;

% define where the data is.... (this is my particular ordering, tho)
rootwavfiles = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_basicdata = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\'
mapping_file = 'DataArrangement_dummy.xlsx';

% load some useful things
T = readtable( [datapath_basicdata, mapping_file] ); % table of data organization
load( [datapath_basicdata, 'voc_detection_map.mat'] ); % load the info about detected vocs
load( [datapath_basicdata, 'voc_prefree_map.mat'] ); % load when the trigger starts
load( [datapath_basicdata, 'vocs_condensed_data.mat'] );
   
last_loaded_wav = "";
prepost_pad = 3e-3;

for k = 1 : numel( vocs_condensed_struct );

    voccol = vocs_condensed_struct(k).colID;
    vocstart = vocs_condensed_struct(k).voc_start;
    vocend = vocs_condensed_struct(k).voc_end;
    wavname = vocs_condensed_struct(k).file;

    % show a large ( +- 5s?) segment where this voc is found
    % figure out which file it is
    fullwav_filename = [ rootwavfiles, wavname ];
    if ( string( fullwav_filename ) ~= last_loaded_wav )
        % load the wav file
        [ wavnow, fs_voc ] = audioread( fullwav_filename );
        last_loaded_wav = string( fullwav_filename );
    end
    
    % get the vocalization chunk...
    chunknow = wavnow( vocstart : vocend );
    
    voc_chunks{k} = chunknow;
    k
end

save voc_chunks voc_chunks;