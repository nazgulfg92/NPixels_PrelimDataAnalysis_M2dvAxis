function [] = work_shownSalineNpixels( ephys_folder, ephys_file, chmap_file, tseg, firstfig )
% 
% This function does the heavy lifting for visualizing neuropixels recordings, with
% spikeGLX. Inputs are as follows:
% 
%     ephys_folder:           path folder to the ephys data.
%     ephys_file:             filename of the data to load
%     chmap_file:             path (including filename) to the channel map file
%     tseg:                   segment of time to plot
%     firstfig:               index of the first figure...
%         
% Some work will have to be done if I wanna generalize this further, but for now
% it's good enough to do what I need it to do.

    ret = [];

    % bring fort the channel map
    load( chmap_file );
    
    % get the ephys file information
    ephysfile = dir( [ephys_folder, '\', ephys_file] );
    % get the meta information on the file
    meta = ReadMeta( ephysfile.name, [ephysfile.folder, '\'] );
    % get some meta information, such as fs and number of channels
    Nchannels = str2double( meta.nSavedChans );
    fs = str2double( meta.imSampRate );

    % memory map for reading a chunk
    nsamples = ephysfile.bytes / 2 / Nchannels; % bytes / 2 as data is uint16
    mmf = memmapfile( [ephys_folder, '\', ephys_file], 'Format', { 'int16', [Nchannels, nsamples], 'data' } );
%     sync_channel = mmf.Data.data(Nchannels, :);
    
    % get me the chunk of the file that was requested
    tseg_samples = round( tseg .* fs );
    ret = mmf.Data.data( 1 : Nchannels, tseg_samples(1) : tseg_samples(2) );
    [ ret, sorted_ycoords ] = pre_process_spikeGLX_LFPs( ret, ycoords );
%     ret = normalize(ret, 2, 'zscore' );
    
    if ( firstfig > 0 ) % check is visualize right here right now
        
        figure( firstfig );
        tv = [ tseg_samples(1) : tseg_samples(2) ] ./ fs;
        plot_penetration_npixels( ret, tv, 0, 2 );
        
        % calculate correlations across channels
        var2test = ret;
        corrmat = nan( Nchannels - 1 );
        for ch1 = 1 : Nchannels - 2
        for ch2 = ch1 : Nchannels - 1 % nchannels is 385, and includes sync
            ccoef = abs(corrcoef( var2test(ch1, :), var2test(ch2, :) ));
            [ corrmat( ch1, ch2 ), corrmat( ch2, ch1 ) ] = deal( ccoef(1, 2), ccoef(2, 1) );
        end
        end
        figure( firstfig + 1 ); imagesc( corrmat ); colorbar; colormap jet;
        
        % show scatter plot of the probe
        [~, ii] = sort(ycoords, 'descend');
        figure( firstfig + 2 ); scatter( xcoords, ycoords, 'x' )
        hold on; scatter( xcoords( ii([65:160,230:320]) ), ycoords( ii( [65:160,230:320] ) ), 'x' );

        % with text
        figure( firstfig + 3 ); text( xcoords(ii), ycoords(ii), string(1:Nchannels-1) ); axis( [0 60 0 10000] )
        hold on; text(xcoords( ii([65:160,230:320]) ), ycoords( ii( [65:160,230:320] ) ), string([65:160,230:320]), 'Color', 'red' );
        
        % show an imagesc
        figure( firstfig + 4 ); imagesc( ret ); 
        colorbar; colormap jet; caxis( [-5 5] );
    end
    
 
    
    
    
    
    
    
end

