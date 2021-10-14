function plot_penetration( lfp_channels, time_vec, norm_style, plot_type )
% Here are the inputs
%     lfp_channels:           the data, ch x samples
%     time_vec:               optional, could be empty... a time vector for the data to plot
%     norm_style:             normalization style for the channels...
%                                     0: no normalization
%                                     1: per channel
%                                     2: across all channels
%     plot_type:              if 1, plots respecting channel order (1 in
%                                   graph is channel 1, etc..)
%                             if 2, plots respecting depth (i.e. flips
%                                   channels)

   
    if ( isempty( time_vec ) ) 
        time_vec = 1:size(lfp_channels, 2); end

    Nchannels = size( lfp_channels, 1 );
    % do some sort of normalization.. option 0 is no norm
    if ( norm_style == 1 ) lfp_channels = normalize( lfp_channels, 2, 'norm', Inf );
    elseif ( norm_style == 2 ) lfp_channels = lfp_channels ./ max( lfp_channels(:) ); end
    
    % add an offset so that they appear on top of each other...
%     lfp_channels = lfp_channels + repmat( [Nchannels : -1 : 1]', [ 1, size(lfp_channels, 2) ] );
    
    if ( plot_type == 1 ) ch_offset = [1: Nchannels]';
    elseif ( plot_type == 2 ) ch_offset = [Nchannels : -1 : 1]'; end
    lfp_channels = lfp_channels + repmat( ch_offset, [ 1, size(lfp_channels, 2) ] );
  
    plot( time_vec, lfp_channels' );
end