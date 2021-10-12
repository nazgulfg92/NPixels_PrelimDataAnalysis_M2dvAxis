
% calculate the length of calls, echo and non_echo.
% still uses the old variable refined varibale with usable and not,
% therefore one needs to check in the loops, but it's alright. It's the
% same
%
% script modified: 2 oct 2020; again 07.07.2021

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


necho = 0;
nnonecho = 0;

fs_voc = 250e3;
lengths_echo = [];
lengths_nonecho = [];

for k = 1 : numel( vocs_condensed_struct )
   
    voc = vocs_condensed_struct(k);
    if ( voc.is_echo )
        necho = necho + 1;
        lengths_echo(necho) = ( voc.voc_end - voc.voc_start ) / fs_voc;
    else
        nnonecho = nnonecho + 1;
        lengths_nonecho(nnonecho) = ( voc.voc_end - voc.voc_start ) / fs_voc; 
    end
        
end

save call_lengths lengths_echo lengths_nonecho;

%% power analyses

% Older comment, but worth to remember:
% Apparently, this needs to be put inside a function for the GPU
% processing. Otherwise, for example, we may run out of memory in the
% GPU.. Although it seems unnecessary, I'll do GPU fft of the calls here,
% just to test it...
%
% So in the future, GPU goes into it's own function, keep the Workspace
% free!!!

load( [datapath_basicdata, 'voc_chunks.mat'] );
tic
for k = 1 : numel( voc_chunks )
    
    voctrace = voc_chunks{k};

    % do the fft with GPU here
    global CHRONUXGPU; 
    CHRONUXGPU = 0; % enable GPU computing with chronux.. faster when not (here). Not worth it for now.. But it works!

    params.tapers = [2 2];
    params.Fs = fs_voc;
    [S, f] = mtspectrumc( voctrace, params );
%     figure(1); subplot( 1, 2, 2 );
%     plot_vector( S, f, 'n' );

    [ ~, peakidx ] = max( S );
    peak_freq(k) = f( peakidx );
    
    % interpolate S and f to a resolution of 100 Hz... it's maybe a good
    % compromise....
    f_target = [ 0 : 100 : 125e3 ]; % 125 kHz is the Nyquist freq
    S_interp = spline( f, S, f_target );

    % store this one
    fft_chunk(k, :) = S_interp;
end
toc
save fft_vocs fft_chunk f_target peak_freq;
