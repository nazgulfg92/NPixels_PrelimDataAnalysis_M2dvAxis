function [Necho, Nnonecho, echoidxs, nonechoidxs ] = get_echo_nonecho_idxs( vocs_info )
    echoidxs = []; nonechoidxs = [];    
    Necho = 0; Nnonecho = 0;
    % get the echo and non-echo idxs...
    for k = 1 : numel( vocs_info ) % same as chunks
        if ( vocs_info(k).is_echo )
           Necho = Necho + 1;
           echoidxs( Necho ) = k;
        else
            Nnonecho = Nnonecho + 1;
            nonechoidxs( Nnonecho ) = k;
        end
    end
end

