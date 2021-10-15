function [ FT_lfp_trials ] = gather_LFPs_freqTuning( mmf, protocol, ephys_trigs, fs_ephys, ycoords, freqs, levels  )
% This function gathers LFPs related to freqTuning and yields them out in a
% trial. The inputs are as follows:
% 
%     mmf:            the memory file map directed at the LFP ephys data from spike GLX
%     protocol:       the structure where the metadata for the protocol recording is.
%     ephys_trigs:    samples where triggers occur in ephys
%     fs_ephys:       sampling rate of the ephys recording
%     ycoords:        the ycoords from the ChannelMap file from spikeGLX.
%                       useful for getting channels out sorted by depth...
%     freq:           a vector specifying the frequencies at which the data should be retrieved
%     levels:         a vector specifying the levels at which the data is to be gathered
%     
% If freq and levels are emptpy, then this returns EVERY freq and lev.
% 
% This outputs
%     
%     FT_lfp_trials:  a matrix with the per-trial LFPs
%         (dimensions: [ ff, lev, tr, ch, samples ] )
%         
% written: 211015;

    if ( nargin < 6 )
        freqs = []; levels = [];
    elseif ( nargin < 7 )
        levels = [];
    end
    
    
    % get some information from the protocol...
    Tplay = protocol.protT;
    freq_list = Tplay.RealFreq; nfreqs = numel( unique(freq_list) );
    lev_list = Tplay.RealLevel; nlevs = numel( unique(lev_list) );
    
    % fix possible missing input arguments
    if ( isempty( freqs ) ) 
        freqs = unique( freq_list ); end;
    if ( isempty( levels ) ) 
        levels = unique( lev_list ); end;
    
    freqs = sort( freqs ); levels = sort( levels ); % get them out sorted
    
    pre_samples = round( protocol.pretime .* fs_ephys );
    post_samples = round( protocol.posttime .* fs_ephys );
    
    % go for all frequencies and levels, gather trials
    % first, pre-allocate for speed
    FT_lfp_trials = [];
    for ff = 1 : numel( freqs )
        
        freqnow = freqs(ff);
        
        for ll = 1 : numel( levels )
            
            levelnow = levels(ll);
            % in which trilas was this ff/ll combo presented?
            trials2use = find( freq_list == freqnow & lev_list == levelnow );
            
            % go throught the trials, and simply gather the LFPs around the
            % trigger in the ephys whose index corresponds to the trial
            % number...
            for m = 1 : numel( trials2use )
                
                % get the lfp chunk
                trigpos = ephys_trigs( trials2use(m) );
                lfp_trial = mmf.Data.data( :, trigpos : trigpos + post_samples );
                
                % post-process the LFP chunk
                % work the chunk
                [ lfp_trial, sorted_ycoords ] = pre_process_spikeGLX_LFPs( lfp_trial(1:end-1, :), ycoords ); % leave out sync
                lfp_trial = normalize( lfp_trial, 2, 'zscore' );
% %                 
%                 figure(1);
%                 tv = [ 0 : size(lfp_trial,2) - 1 ] ./ fs_ephys;
%                 plot_penetration_npixels( lfp_trial, tv, 1, 2 ); axis tight;

                % now let's save this particular trial
                if ( isempty( FT_lfp_trials ) )
                    FT_lfp_trials = zeros( numel(freqs), numel(levels), protocol.Ntrials, 384, size(lfp_trial, 2) );
                end
                
                FT_lfp_trials( ff, ll, m, :, : ) = lfp_trial;
            end
            
            % report
            fprintf( 'done gathering freq %d, level %d\n\n', ff, ll );
        end
    end
end

