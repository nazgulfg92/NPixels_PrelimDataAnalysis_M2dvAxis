% This script gets the LFP segments from the neuropixels recordings associated to
% the vocalizations. This is a preliminary one, so for now we're dealing with
% one recording column, one recording session, one wav file. Should be easy
% enough. Later I can generalize from here..

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

load( [datapath_matvars, 'vocs_condensed_data.mat'] );
load( [datapath_matvars, 'ChanMap_fullShankCol_mine.mat'] );

T = readtable( [ datapath_matvars, 'DataArrangement_dummy.xlsx' ] );

% get the LFP file information
lfpfile = dir( [rootLFPfiles, lfp_filename] );
% get the meta information on the file
meta = ReadMeta( lfpfile.name, [lfpfile.folder, '\'] );
% get some meta information, such as fs and number of channels
Nchannels = str2double( meta.nSavedChans );
fsLFP = str2double( meta.imSampRate );

nsamples = lfpfile.bytes / 2 / Nchannels; % bytes / 2 as data is uint16
mmf = memmapfile( [rootLFPfiles, lfp_filename], 'Format', { 'int16', [Nchannels, nsamples], 'LFPsfile' } );
sync_channel = mmf.Data.LFPsfile(Nchannels, :);

%% gather the vocs
clc;
% okay, now go per vocalization and gather the LFP that belongs to that
% specific one. save into a matrix, simple as that for now..

% but first, somet things
% get the when the trigger of the vocalization occurs
fsvoc = 192e3;
load( [ datapath_matvars, 'init_trigger_and_silence.mat' ] );
wavtrigger = basic_wavfile_data.WavTrigger;

% find the ephys trigger, there should be one only.
[ ~, ephys_trigger ] = findpeaks( -double(sync_channel) );
ephys_trigger = ephys_trigger ./ fsLFP;

% define some things
prepost_time = 3; % in seconds
prepost_samples = round( prepost_time .* fsLFP );

% preallocate some variables for speed
lfp_vocs_npixels = zeros( numel( vocs_condensed_struct ), Nchannels-1, prepost_samples * 2 ); % minus sync channel

for vv = 6 : 6% numel( vocs_condensed_struct )
   
    % align voc with the LFP
    [ voc_time_start, trigger_offset ] = correct4trigger( vocs_condensed_struct(vv).voc_start ./ fsvoc, ...
                                                    ephys_trigger, wavtrigger );
    [ voc_time_end, trigger_offset ] = correct4trigger( vocs_condensed_struct(vv).voc_end ./ fsvoc, ...
                                                    ephys_trigger, wavtrigger );
                                                
    offset = ( randi([2500, 5000]*40) * randsample([-1 1], 1) );
%     offset = 0;
    voc_LFPsample_start = round( voc_time_start .* fsLFP ) + offset;
    voc_LFPsample_end = round( voc_time_end .* fsLFP  );
    
    % now comes the process of finding the LFP chunk
    % but it should be easy
    chunk_start = voc_LFPsample_start - prepost_samples;
    chunk_end = voc_LFPsample_start + prepost_samples - 1;
    chunknow = mmf.Data.LFPsfile( 1 : Nchannels - 1, chunk_start : chunk_end );
    chunknow = double( chunknow );
    
    % sort the chunk according to the typical preprocessing of raw SpikeGLX
    % data....
    [ chunk_postproc, sorted_ycoords ] = pre_process_spikeGLX_LFPs( chunknow, ycoords );
    chunk_postproc = normalize( chunk_postproc, 2, 'zscore' );
    figure(1); plot_penetration_npixels( chunk_postproc, [0 : size(chunk_postproc,2) - 1] ./ fsLFP - prepost_time, 1, 2 );
    % store the chunk
    lfp_vocs_npixels( vv, :, : ) = chunk_postproc;
end
offset / fsLFP
%% calculate correlations across channels
var2test = chunk_postproc;
corrmat = nan( Nchannels - 1 );
for ch1 = 1 : Nchannels - 2
for ch2 = ch1 : Nchannels - 1 % nchannels is 385, and includes sync
    ccoef = abs(corrcoef( var2test(ch1, :), var2test(ch2, :) ));
    [ corrmat( ch1, ch2 ), corrmat( ch2, ch1 ) ] = deal( ccoef(1, 2), ccoef(2, 1) );
end
end
figure(3); imagesc( corrmat ); colorbar; colormap jet;

%% show scatter plot of the probe
[~, ii] = sort(ycoords, 'descend');
figure(4); scatter( xcoords, ycoords, 'x' )
hold on; scatter( xcoords( ii([65:160,230:320]) ), ycoords( ii( [65:160,230:320] ) ), 'x' );

% with text
figure(5); text( xcoords(ii), ycoords(ii), string(1:Nchannels-1) ); axis( [0 60 0 10000] )
hold on; text(xcoords( ii([65:160,230:320]) ), ycoords( ii( [65:160,230:320] ) ), string([65:160,230:320]), 'Color', 'red' ); 