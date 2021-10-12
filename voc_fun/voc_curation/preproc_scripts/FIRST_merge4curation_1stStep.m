% This script merges for the first time the information about the pre-free
% with the information about each of the vocalizations....
%
% IT ONLY BRINGS FORTH THE ONES THAT ARE CANDIDATES FOR PRE-FREE (EITHER
% WITH 1s OR WITH 500 ms... 

clc;
clear all;

% define where the data is.... (this is my particular ordering, tho)
datapath = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_basicdata = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\'
mapping_file = 'DataArrangement_dummy.xlsx';

% load some useful things
T = readtable( [datapath_basicdata, mapping_file] ); % table of data organization
load( [datapath_basicdata, 'voc_detection_map.mat'] ); % load the info about detected vocs
load( [datapath_basicdata, 'voc_prefree_map.mat'] ); % load when the trigger starts

keys = voc_detection_map.keys;
voc_detectCurated_map = containers.Map;
for k = 1 : numel( keys )
    
    key = keys{k};
    voc_datak = voc_detection_map( key );
    voc_prefreek = voc_prefree_map( key );
    voc_postfreek = [];
    
    % figure out who is post_free for 0.5 and for 1s
    for m = 1 : size( voc_prefreek, 2 ) - 1
        voc_postfreek( :, m ) = voc_prefreek( :, m + 1 );
    end
    voc_postfreek( :, size( voc_prefreek, 2 ) ) = 1;
    
    % there's no other way but this, now...
    voc_datak.voc_start = voc_datak.voc_start( voc_prefreek(1,:) == 1 );
    voc_datak.voc_end = voc_datak.voc_end( voc_prefreek(1,:) == 1 );
    voc_datak.is_echo = voc_datak.is_echo( voc_prefreek(1,:) == 1 );
    voc_datak.power_ratios = voc_datak.power_ratios( voc_prefreek(1,:) == 1 );
    voc_datak.peakF = voc_datak.peakF( voc_prefreek(1,:) == 1 );
    % and the very own pre_free
    voc_datak.pre_free = voc_prefreek( :, voc_prefreek(1,:) == 1 );
    voc_datak.post_free = voc_postfreek( :, voc_prefreek(1,:) == 1 );
    
    voc_detectCurated_map( key ) = voc_datak;
end

save voc_detectCurated_map voc_detectCurated_map;