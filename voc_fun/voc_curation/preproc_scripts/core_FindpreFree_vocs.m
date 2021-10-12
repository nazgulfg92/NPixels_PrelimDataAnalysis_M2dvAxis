% This script takes the data on detected vocalizations and determines those
% that have pre-times of 0.5 or 1 second. These are the only ones I'll
% curate by hand with a GUI later.

clc;
clear all;

fs_vocs = 192e3;

% define where the data is.... (this is my particular ordering, tho)
datapath = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_basicdata = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\'
mapping_file = 'DataArrangement_dummy.xlsx';

% load some useful things
T = readtable( [datapath_basicdata, mapping_file] ); % table of data organization
load( [datapath_basicdata, 'voc_detection_map.mat'] ); % load the info about detected vocs
load( [datapath_basicdata, 'init_trigger_and_silence.mat'] ); % load when the trigger starts

% go per wav file and figure out vocs here that are pre-free, 1 and 0.5 s
voc_prefree_map = containers.Map;
tot_pre500 = 0; tot_pre1000 = 0;

for k = 1 : size( T, 1 )

	tempT = T( k, : );
    
    rec_prot_no = tempT.Prot_No;
    if ( isnan( rec_prot_no ) | rec_prot_no > 2 ) % it's not vocalization file
        continue; end;
    
    rec_date = num2str( tempT.Date );
    rec_session = tempT.Session;
    rec_animal_no = tempT.AnimalNo_;
    rec_col_no = tempT.ColumnNo_;
    rec_wav_file = tempT.WavFile;
	
	% make a key to find in the metadata of detected vocs
	keynow = sprintf( '%sCol%d', rec_wav_file{1}, rec_col_no );
	vocs_datak = voc_detection_map(keynow);
	
    % find the trigger in the basic_wavfile_data
    idx_wavdata = find( string( rec_wav_file{1} ) == string( { basic_wavfile_data.FileName } ) & ...
                        rec_col_no == [ basic_wavfile_data.ColId ] );
    triggerT = basic_wavfile_data( idx_wavdata ).WavTrigger;
		
	% go per vocalization... take only those that are AT LEAST 30 s past trigger
	pre_free = zeros( 2, numel( vocs_datak.voc_start ) );
	for m = 2 : numel( vocs_datak.voc_start ) % the first thing in the recording is at least the trigger
		% segment for pre time check
		st_voc = vocs_datak.voc_start(m) ./ fs_vocs;
		end_lastvoc = vocs_datak.voc_end(m - 1) ./ fs_vocs;
		if ( st_voc < triggerT | abs( st_voc - triggerT ) < 30 ) continue; end;
		pre_free( 1, m ) = ( st_voc - end_lastvoc ) > 0.5;
		pre_free( 2, m ) = ( st_voc - end_lastvoc ) > 1;
		% this also works for checking that the post is free (a post-free voc preceeds a pre_free voc)
	end
	
	voc_prefree_map( keynow ) = pre_free;
    
    tot_pre500 = tot_pre500 + sum( pre_free(1, :) );
    tot_pre1000 = tot_pre1000 + sum( pre_free(2, :) );
end

save voc_prefree_map voc_prefree_map;