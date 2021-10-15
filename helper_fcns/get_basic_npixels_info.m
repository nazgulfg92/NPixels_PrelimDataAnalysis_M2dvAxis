function [ meta, Nchannels, fs_ephys, nsamples, mmf ] = get_basic_npixels_info( ephysfile )
    meta = ReadMeta( ephysfile.name, [ephysfile.folder, '\'] );
    Nchannels = str2double( meta.nSavedChans );
    fs_ephys = str2double( meta.imSampRate );
    nsamples = ephysfile.bytes / 2 / Nchannels; % bytes / 2 as data is uint16
    mmf = memmapfile( [ephysfile.folder, '\', ephysfile.name], 'Format', { 'int16', [Nchannels, nsamples], 'data' } );
end

