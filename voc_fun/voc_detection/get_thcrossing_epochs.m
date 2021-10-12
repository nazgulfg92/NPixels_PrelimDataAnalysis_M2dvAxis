function [ belowTh_epochs, aboveTh_epochs ] = get_thcrossing_epochs( data, zth, safety_pad )

    aboveTh_epochs = [];
    belowTh_epochs = [];
    
    % start by finding all the crossings of the threshold
    th_crossings = find( data > zth );
    % but also, mark them with ones
    mask_overTh = data > zth;
    cum_maskOTh = cumsum( mask_overTh );
    
    % I think simplest is to go per sample, and figure out which one counts
    % as free of movement; then I can group them, and find the set
    % differences with all indeces. This gives me indices that are
    % movement. Then I group them too, and get epochs, instead of simple
    % indices.
    n = numel(data);
    below_th = zeros( size(data) );
    for m = 1 : n
        
        % figure out the n - safety_pad samples
        last2check = max( m - safety_pad + 1, 1 );
        next2check = min( m + safety_pad - 1, n );
        
        % so, there cannot be any crossings in the last2check : next2check
        % the number of crossings cum-sum table should get me
        num_crossings = cum_maskOTh(next2check) - cum_maskOTh(last2check) + ...
                          mask_overTh(last2check);
                      
        if ( ~num_crossings ) 
            below_th(m) = 1; end;
    end
    
%     t = [1 : numel(data)] / 192;
%     figure; plot( t, data );
%     xx = find( ~mov_free );
%     hold on; scatter( t(xx), data(xx) );
    
    % fine, now find continuous epochs above threshold, and
    % continuous epochs below threshold
    
%     last_epoch_type = mov_free(1); %-1 indicates no change, 0 is mov, 1 is free
    nepochs_belowTh = 0;
    nepochs_overTh = 0;
    m = 1; while m <= n
       
        mm = m + 1;
        while ( mm <= n & below_th(m) == below_th(mm) )
            mm = mm + 1; end;
        mm = mm - 1;
        
        % check if it's a clean epoch
        if ( below_th(m) ) 
            nepochs_belowTh = nepochs_belowTh + 1;
            belowTh_epochs(nepochs_belowTh, :) = [ m, mm ];
        else
            nepochs_overTh = nepochs_overTh + 1;
            aboveTh_epochs(nepochs_overTh, :) = [m, mm];
        end
        
        m = mm + 1;
    end
    
    2+2;
end

