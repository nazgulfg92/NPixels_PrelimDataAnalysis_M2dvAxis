function ret = pre_process_spikeGLX_LFPs( x, ycoords )
    % pre process SpikeGLX LFP data
    ret = x;
    ret = double(ret);
    ret = ret - median(ret, 2); % subtract median
    % organize according to depth
    [ ~, dist2tip_idx ] = sort( ycoords );
    dist2tip_idx = flip( dist2tip_idx ); % first index is the farthest from tip, i.e. the most superficial eletrodes
    ret = ret( dist2tip_idx, : );
end