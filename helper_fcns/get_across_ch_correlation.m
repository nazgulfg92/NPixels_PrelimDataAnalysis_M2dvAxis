function corrmat = get_across_ch_correlation( var2test )
    Nchannels = size(var2test, 1);
    corrmat = nan( Nchannels );
    for ch1 = 1 : Nchannels - 1
    for ch2 = ch1 : Nchannels
        ccoef = abs(corrcoef( var2test(ch1, :), var2test(ch2, :) ));
        [ corrmat( ch1, ch2 ), corrmat( ch2, ch1 ) ] = deal( ccoef(1, 2), ccoef(2, 1) );
    end
    end
end