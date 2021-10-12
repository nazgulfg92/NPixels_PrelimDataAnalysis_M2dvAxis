function [ voc_start_dummy, voc_end_dummy, is_echo, power_ratios, peakF ] = ...
        find_vocalizations( x, fs, rms_wl, save_chunks_flag, chunk_save_path, chunk_base_name, threshold_period )
% % This function attempts to find the vocalizations in a wav file. It will
% % also probably attempt an early classification in echolocation and comm.
% % signals, based on the peak frequency of the power spectrum of each utterance.
% % 
% % Tthe function expects me to give it a period in which to find a threshold. 
% % It will find the RMS envelope of the whole thing,
% % go the peridod I told it to look for, and calculate the mean there and then the
% % threshold in STDs is based on that mean. This helps against
% % upward-biased threshold (from very loud calls or whatever).
% % 
% % What we'll do, is run matlab's function envelope, with 'rms' and a wl
% % of 100 (input parameter), which seems to work just fine.... 
% % 
% % Inputs are as follows:
% %     x, fs:              audio signal and fs
% %     rms_wl:             window length for RMS envelope (100 is a good value)
% %     save_chunks_flag:   1 if chunks .wav are to be saved
% %     chunk_save_path:    path where to save the chunks
% %     chunk_base_name:    base name for the chunks... i.e. chunks will be named
% %                         as [ base_name, '_0001.wav' ]
% %     threshold_period    in seconds. the prediod in which to find the
% %                         thresholsd

% % Outputs, as follows:
% %     voc_start_dummy:    vector with start of all vocalizations (samples)
% %     voc_end_dummy:      vector with end of all vocalizations (samples).
% %                         A vocaliation goes from voc_start_dummy : voc_end_dummy in x
% %     is_echo:            logic array with whether each vocalization is an echolocation call
% %     power_ratios:       ratio of power in low freqs (<50 kHz) or high freqs (> 50 kHz)
% %     peakF:              peak frequency in the vocalizations' spectra
% 
% %%
% 
% clc;
% [ x, fs ] = audioread( 'T0000047.wav' );
% 
% tv = [ 0 : numel( x ) - 1 ] ./ fs;
% figure(1); plot( tv, x );
% 
%% what about finding an envelope with Matlab's function....
[ env_x, ~ ] = envelope( x, rms_wl, 'rms' );
% figure( 1 ); hold on; plot(tv, env_x, 'k' );
% xlim( xx ); ylim( yy );

th_period_samples = threshold_period .* fs;

mu_env = mean( env_x( th_period_samples(1) : th_period_samples(2) ) );
sigma_env = std( env_x( th_period_samples(1) : th_period_samples(2) ) );
x_env_norm = ( env_x - mu_env ) ./ sigma_env;
% figure( 2 ); clf; plot( [0 : numel(x) - 1] ./ fs, x ); 
% figure(2); plot( [0 : numel(x) - 1] ./ fs, x_env_norm ); 
% xlim( xx );

%% find threshold crossings from amplitude base

std_threshold = 10;

curr_idx = 1e-3 * fs;

voc_start = [];
voc_end = [];

% let's try finding semgments above threshold (this could be a complexity
% improvement to what I used to do for detection)
[ ~, aboveTh ] = get_thcrossing_epochs( x_env_norm, std_threshold, 1 );
voc_start = aboveTh(:, 1)'; voc_end = aboveTh(:, 2)';

% figure(2); hold on;
% scatter( voc_start ./ fs, repmat(3.5, size(voc_start)), 'xg' );
% scatter( voc_end ./ fs, repmat(3.5, size(voc_start)), 'xm' );

% correct for length (no one that has less than .1 ms is a real vocalization)
idx_corr = find( ( voc_end - voc_start ) ./ fs > .1e-3 );
voc_start = voc_start( idx_corr );
voc_end = voc_end( idx_corr );

% check and merge different surviving peaks within 2 ms from each other
critical_interval = 2e-3;
call_intervals = voc_start( 2 : end ) - voc_end( 1 : end - 1 ) ;
voc_too_close = find( call_intervals ./ fs < critical_interval );

% if vocalizations are too close, then merge them
% merge until there's no-one else to merge
voc_start_dummy = voc_start;
voc_end_dummy = voc_end;
voc_too_close_dummy = voc_too_close;

while ( ~isempty( voc_too_close_dummy ) )
    idxnow = voc_too_close_dummy( 1 ); % draw from top
    curr_start = voc_start_dummy( idxnow );
    curr_end = voc_end_dummy( idxnow + 1 );
    % update voc_start and voc_end
    voc_start_dummy( idxnow + 1 ) = curr_start;
    voc_end_dummy( idxnow + 1 ) = curr_end;
    voc_end_dummy( idxnow ) = curr_end;
    voc_start_dummy( idxnow ) = curr_start;
    % make them unique
    voc_end_dummy = unique( voc_end_dummy );
    voc_start_dummy = unique( voc_start_dummy );
    % update voc_too_close
    call_intervals = voc_start_dummy( 2 : end ) - voc_end_dummy( 1 : end - 1 ) ;
    voc_too_close_dummy = find( call_intervals ./ fs < critical_interval );
end
% 
% figure(2); hold on;
% scatter( voc_start_dummy ./ fs, repmat(3.5, size(voc_start_dummy)), 'ob' );
% scatter( voc_end_dummy ./ fs, repmat(3.5, size(voc_start_dummy)), 'or' );
% 
% figure(2); hold on;
% scatter( setdiff( voc_start, voc_start_dummy ) ./ fs, repmat(3.5, size(setdiff( voc_start, voc_start_dummy ))), 'xr' );
% scatter( setdiff( voc_end, voc_end_dummy ) ./ fs, repmat(3.5, size(setdiff( voc_start, voc_start_dummy ))), 'xr' );

%% find and save vocalization chunks
time_pre = 1e-3; % time to take before voc.
time_post = 1e-3; % time to take after voc.

if ( save_chunks_flag & nargin >= 6 ) 
    for ii = 1 : numel( voc_start_dummy )

        st_now = voc_start_dummy( ii ) - ceil( time_pre * fs ) + 1;
        end_now = voc_end_dummy( ii ) + ceil( time_post * fs ) - 1;

        chunk = x( st_now : end_now );
        chunk_name = sprintf( '%s%04d.wav', chunk_base_name, ii );
        chunk_path_name = [ chunk_save_path, '\', chunk_name ];
        audiowrite( chunk_path_name, chunk, fs ); 
    end
end
%% attempt an early classification of non-echo vs. echo calls
% Echolocation calls will alway have peak frequency above 50 kHz, whereas
% non-echolocation calls will have peak frequency 5 <= peak_f <= 50 kHz

for ii = 1 : numel( voc_start_dummy )
    
    call_now = x( voc_start_dummy(ii) : voc_end_dummy(ii) );
    params.Fs = fs;
    params.tapers = [2 2];
    [ S, f ] = mtspectrumc( call_now, params );
%     figure(4); subplot( 6, 10, mod(ii, 60) );
%     plot( f, S );
    
    % find the energy concentration:
    fboundary = find( f < 50e3, 1, 'last' );
    hf_power = trapz( f( fboundary + 1 : end ), S( fboundary + 1 : end ) );
    lf_power = trapz( f( 1 : fboundary ), S( 1 : fboundary ) );
    
    [ ~, mm ] = max( S );
    peakF(ii) = f( mm );
    
    is_echo(ii) = ( peakF(ii) > 50e3 & lf_power / hf_power < .25 );
    power_ratios(ii) = lf_power / hf_power;
end

% figure; histogram( peakF( ~is_echo ), 'Normalization', 'probability' ); 
% hold on; histogram( peakF( is_echo ),'Normalization', 'probability' );