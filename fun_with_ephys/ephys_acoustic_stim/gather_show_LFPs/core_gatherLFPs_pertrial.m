% Okay, so this script goes around and gathers all LFP trials from a given
% penetration, protocol file, etc.
% The thing that comes out depends on the type of stimulation protocol.
% If it's a freq tuning, then it's simply a matrix:
%     [ ff, lev, tr, ch, samples ] in dimension.
%         ff are frequencies teste (indices, obviously)
%         lev are levels
%         tr are trials
%         ch are channels
%         samples are just time samples
% If it's a sound battery protocol, then we have (not it's a cell)
%     { ss, tr } -> [ch, samples]
%         ss are the stimuli
%         tr are the trials for a given stim
%         ch are channels
%         samples are samples duh
% 
% This can later be made into a function that allows me to load several
% days of neuropixels recordings.
%
% written: 211015

clc;
clear all;

clc;
clear all;

% prepare and load some basic shit
addpath( 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\helper_fcns\' );
% some paths
ephys_datapath = 'E:\Francisco\Neuropixels_Prelim\PrelimData_M2dorsoventral\210922\npixels_ephys\';
protocol_datapath = 'E:\Francisco\Neuropixels_Prelim\PrelimData_M2dorsoventral\210922\rec_metadata\';
datapath_matvars = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\';
lfp_fileprefix = 'lf.bin';

% load some basic shit
load( [datapath_matvars, 'vocs_condensed_data.mat'] );
load( [datapath_matvars, 'ChanMap_fullShankCol_mine.mat'] );
T = readtable( [datapath_matvars, 'DataArrangement_NpixelsPrelimM2dvAxis.xlsx'] );

%% define protocol and column to gather
% also get names of things to load

k = 1;
protnow = 4; % protocols: 1-3 voc... 4,5 - FT, 6-9 - NatCalls..
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

% load ephys things
ephysfile = dir( [ephys_datapath, ephys_colname, ephys_filename] );
[ meta, Nchannels, fs_ephys, nsamples, mmf ] = get_basic_npixels_info( ephysfile );

% load the metadata of the recording (something I've done myself)
protfilename = [ Tnow.ProtocolFile{1}, '.mat' ]; 
protocol = load( [ protocol_datapath, protfilename ] );
% load the ephys (partial load)
[ meta, Nchannels, fs_ephys, nsamples, mmf ] = get_basic_npixels_info( ephysfile );

% get me the sync_channel, and the ephys triggers
sync_channel = double( mmf.Data.data( Nchannels, : ) ); % last channel is sync.
[ ~, ephys_trigs ] = findpeaks( -sync_channel );

%% gather LFPs into variables

if ( protnow < 4 ) 
    warning( 'THIS IS NOT FOR VOC FILES, AND YOU USE ONE HERE' );
elseif ( protnow < 6 ) 
    FT_lfp_trials = gather_LFPs_freqTuning( mmf, protocol, ephys_trigs, fs_ephys, ycoords );
elseif ( protnow < 10 ) 
    gather LFPs_soundBattery();
end

%%
aa = squeeze( FT_lfp_trials( 3, 1, :, :, : ) );
aa = squeeze( mean( aa ) );
figure(1);
tv = [ 0 : size(aa,2) - 1 ] ./ fs_ephys;
plot_penetration_npixels( aa, tv, 2, 2 );

figure(2); subplot(1, 2, 1);
imagesc( tv, [1:Nchannels-1], aa ); colormap jet;

subplot(1,2,2);
corrmat = get_across_ch_correlation( aa );
imagesc( corrmat ); colorbar; colormap jet;
