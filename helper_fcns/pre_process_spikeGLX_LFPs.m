function [ ret, sorted_ycoords ]= pre_process_spikeGLX_LFPs( x, ycoords )
    % pre process SpikeGLX LFP data
    ret = x;
    
    ret = double(ret);
    ret = ret - median(ret,2); % subtract median per channel, to make them centered at 0 (some offset correction)
    ret = ret - median(ret); % subtract median for all channels
    
    % organize according to depth
    [ sorted_ycoords, dist2tip_idx ] = sort( ycoords, 'descend' ); % ycoords measure from tip.. 
                                                                   % I want my matrix organized from the base...
                                                                   % (i.e. row 1 is the topmost channel in brain)
    ret = ret( dist2tip_idx, : );
end