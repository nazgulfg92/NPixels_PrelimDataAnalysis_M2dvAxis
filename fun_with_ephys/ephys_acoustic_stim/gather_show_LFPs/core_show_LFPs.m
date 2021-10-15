% This script makes it possible to read LFPs recorded with Npixels and visualize them.
% It's a good start to familiarize myself with the data manipulation, etc..
% 
% written: 211015;

clc;
clear all;

% prepare and load some basic shit
addpath( 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\helper_fcns\' );
% some paths
ephys_datapath = 'E:\Francisco\Neuropixels_Prelim\PrelimData_M2dorsoventral\210922\npixels_ephys\';
datapath_matvars = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\';
lfp_fileprefix = 'lf.bin';

% load some basic shit
load( [datapath_matvars, 'vocs_condensed_data.mat'] );
load( [datapath_matvars, 'ChanMap_fullShankCol_mine.mat'] );
T = readtable( [datapath_matvars, 'DataArrangement_NpixelsPrelimM2dvAxis.xlsx'] );

%% define which stuff I wanna visualize
% also get names of things to load

k = 1;
protnow = 5; % protocols: 1-3 voc... 4,5 - FT, 6-9 - NatCalls..
tseg = [10 15]; % time segments, in seconds

% construct the filenames
% find the protocol and the column in the table
Tnow = T( T.ColumnNo_ == k & T.Prot_No == protnow, : );
% get filename, col name etc
ephys_filename = [ Tnow.EphysFile{1}, '.', lfp_fileprefix ];
% get col name
expr_prefix = '_t\d'; % to find where the triggers are indicated
[ ~, idx1 ] = regexp( ephys_filename, expr_prefix, 'match' );
expr_prefix = 'imec\d'; % to find the indentifier of the triggers are indicated
[ guynow, idx2 ] = regexp( ephys_filename, expr_prefix, 'match' );
imecID = sscanf( guynow{1}, 'imec%d' );
ephys_colname = [ ephys_filename( 1 : idx1 - 1 ) ];
ephys_colname = [ ephys_colname, '\', ephys_colname, sprintf( '_imec%d', imecID), '\' ];

%% get to work, show
clc;
ephysfile = dir( [ephys_datapath, ephys_colname, ephys_filename] );
[ meta, Nchannels, fs_ephys, nsamples, mmf ] = get_basic_npixels_info( ephysfile ); 

% get the chunk, sycn channel, and trigger positions, maybe plot
tseg_samples = round( tseg .* fs_ephys );
chunk = double( mmf.Data.data( :, tseg_samples(1) : tseg_samples(2) ) );
sync_ch = chunk( Nchannels, : );
[ xx, ephys_trigs ] = findpeaks( -sync_ch ); % trigs go down
figure(1); plot( sync_ch );
hold on; scatter( ephys_trigs, xx );

% work the chunk
[ chunk, sorted_ycoords ] = pre_process_spikeGLX_LFPs( chunk, ycoords );
figure(2);
tv = [ tseg_samples(1) : tseg_samples(2) ] ./ fs_ephys;
plot_penetration_npixels( chunk, tv, 1, 2 ); axis tight;

% calculate correlations across channels
var2test = chunk;
corrmat = nan( Nchannels - 1 );
for ch1 = 1 : Nchannels - 2
for ch2 = ch1 : Nchannels - 1 % nchannels is 385, and includes sync
    ccoef = abs(corrcoef( var2test(ch1, :), var2test(ch2, :) ));
    [ corrmat( ch1, ch2 ), corrmat( ch2, ch1 ) ] = deal( ccoef(1, 2), ccoef(2, 1) );
end
end
figure( 3 ); imagesc( corrmat ); colorbar; colormap jet;

% show scatter plot of the probe
[~, ii] = sort(ycoords, 'descend');
figure( 4 ); scatter( xcoords, ycoords, 'x' )
hold on; scatter( xcoords( ii([65:160,230:320]) ), ycoords( ii( [65:160,230:320] ) ), 'x' );

% with text
figure( 5 ); text( xcoords(ii), ycoords(ii), string(1:Nchannels-1) ); axis( [0 60 0 10000] )
hold on; text(xcoords( ii([65:160,230:320]) ), ycoords( ii( [65:160,230:320] ) ), string([65:160,230:320]), 'Color', 'red' );

% show an imagesc
figure( 6 ); imagesc( chunk ); 
colorbar; colormap jet; caxis( [-50 50] );
