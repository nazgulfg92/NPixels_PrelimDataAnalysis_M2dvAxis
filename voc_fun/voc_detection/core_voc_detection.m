% This script will just cycle through all my WAV data and find the
% vocalization chunks.. and store them in a folder right there...
% you'll see...
% 
% We'll filter the whole file over 50 kHz and run the detection again. In
% the end, calls that are within 1 ms from each other will be merged. Then,
% we'll go back to checking them individually.

clc;
clear all;

% define where the data is.... (this is my particular ordering, tho)
datapath = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_basicdata = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\'
mapping_file = 'DataArrangement_dummy.xlsx';

% 
% 
% % define where you wanna store the chunks
% chunk_folder = 'D:\Data\_____FAF_AC_A16x2_voc\voc_chunks\';

T = readtable( [datapath_basicdata, mapping_file] ); % load the data organization
load( [datapath_basicdata, 'init_trigger_and_silence.mat'] );

idxs_colNo_protNo = [];
[ Nitems, ~ ] = size( T );

voc_detection_map = containers.Map;

for k = 1 : Nitems
    
    tempT = T( k, : );
    
    rec_prot_no = tempT.Prot_No;
    if ( isnan( rec_prot_no ) | rec_prot_no > 2 ) % it's not vocalization file
        continue; end;
    
    rec_date = num2str( tempT.Date );
    rec_session = tempT.Session;
    rec_animal_no = tempT.AnimalNo_;
    rec_col_no = tempT.ColumnNo_;
    rec_wav_file = tempT.WavFile;
    
    % with the above, it's easy to form the path..
    path2wav = [ datapath, '\', rec_wav_file{1} ];
    
%     now load the corresponding wav file
    [ x, fs ] = audioread( path2wav );
    
    % make new folder within this date and session:
    [ ~, ff, ~ ] = fileparts( rec_wav_file{1} ); % make my life easier
    path_chunks = [ datapath, num2str( rec_col_no ), '\', ff, '\' ];
    mkdir( path_chunks );
    
    % before running, find the rather silent period for detection baseline
    % find the period in the basic_wavfile_data
    idx_wavdata = find( string( rec_wav_file{1} ) == string( { basic_wavfile_data.FileName } ) & ...
                        rec_col_no == [ basic_wavfile_data.ColId ] );
    th_periods = basic_wavfile_data( idx_wavdata ).WavDetectSilence;
    
    [ voc_start, voc_end, is_echo, power_ratios, peakF ] = ...
        find_vocalizations( x, fs, 100, 1, path_chunks, rec_wav_file{1}, th_periods);

    % make a key for the detection. the key is the name of the wav file and
    % the number of the column...
    keynow = sprintf( '%sCol%d', rec_wav_file{1}, rec_col_no );
    voc_detection_map( keynow ) = ...
         struct( 'voc_start', voc_start, 'voc_end', voc_end, ...
        'is_echo', is_echo, 'power_ratios', power_ratios, 'peakF', peakF, 'file', rec_wav_file{1} );
    
	% give status
    fprintf( 'done with detection, wav -> %s, colID -> %d\n', rec_wav_file{1}, rec_col_no );
end

save voc_detection_map voc_detection_map;