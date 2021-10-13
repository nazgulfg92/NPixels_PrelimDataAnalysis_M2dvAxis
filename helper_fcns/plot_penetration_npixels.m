function plot_penetration( lfp_channels, time_vec, norm_style )
% Here are the inputs
%     lfp_channels:           the data, ch x samples
%     time_vec:               optional, could be empty... a time vector for the data to plot
%     norm_style:             normalization style for the channels...
%                                     0: no normalization
%                                     1: per channel
%                                     2: across all channels

   
    if ( isempty( time_vec ) ) 
        time_vec = 1:size(lfp_channels, 2); end

    Nchannels = size( lfp_channels, 1 );
    % normalize across channels, only to make it easy
    if ( norm_style == 1 ) lfp_channels = normalize( lfp_channels, 2, 'norm', Inf );
    elseif ( norm_style == 2 ) lfp_channels = lfp_channels ./ max( lfp_channels(:) ); end
    
    % add an offset so that they appear on top of each other...
    lfp_channels = lfp_channels + repmat( [Nchannels : -1 : 1]', [ 1, size(lfp_channels, 2) ] );
  
    plot( time_vec, lfp_channels' );
end