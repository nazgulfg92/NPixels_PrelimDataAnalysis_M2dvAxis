% gets a condensed list of vocalizations from the
% files produced by the curation gui

clc;
clear all;

datapath = 'curation_gui\curatedVocMaps\';

% get the files there and find the latest (they
% ordered by date, and alphabetically)
filesnow = dir( [datapath, '*detectCurated*.mat'] );
load( [ datapath, filesnow(end).name ] );

% the var that I want in the end
vocs_condensed_map = containers.Map;
struct_idx = 0;

mykeys = keys( voc_detectCurated_map );
cumul_idx = 0; % this is for defining the original index of the call
        % note that by original, I mean in the bunch of calls I used for
        % the curation already (calculated pre-free by algorithm).

for k = 1 : numel( mykeys )

	keynow = mykeys{ k };
	aux = voc_detectCurated_map(keynow);
	
	% get the column number
	colID = split( keynow, '.wavCol' );
	colID = str2num( colID{2} );
	
	% now keep only the vocalizations that are
	% both labeled as a TRUE voc and as PRE-FREE.
    
    % I made a mistake in the app with the pre-free. I have lost the info
    % about the 1s, but at least I have the info. The indexes were
    % calculated using is_echo, which is fortunately 1D. But pre-free was
    % 2D, so I'm using 1D indices there. So if I say, for example, voc 3,
    % then in prefree thats not [1, 3], rather [1,2] (as matlab travaerses
    % variables column first). I have to fix that here...
	goodidx = find( aux.is_voc );
	[ pre_freeI, pre_freeJ ] = ind2sub( size(aux.pre_free), goodidx );
    good_goodidx = logical([]);
	for m = 1 : numel(goodidx)
		good_goodidx(m) = logical( aux.pre_free( pre_freeI(m), pre_freeJ(m) ) );
    end
    good_idxs = goodidx( good_goodidx );
	
	% do it per vars....
	voc_start = aux.voc_start( good_idxs );
	voc_end = aux.voc_end( good_idxs );
	is_echo = aux.is_echo( good_idxs );
	power_ratios = aux.power_ratios( good_idxs );
	peakF = aux.peakF( good_idxs );
	file = aux.file;
	pre_free = aux.pre_free( good_idxs );
	post_free = aux.post_free( good_idxs );
	is_voc = aux.is_voc( good_idxs );
    % get the original idxs
    original_idx = good_idxs + cumul_idx;
	
	% store it in the map
	vocs_condensed_map( keynow ) = struct( 'voc_start', voc_start, 'voc_end', voc_end, 'is_echo', is_echo, ...
										  'power_ratios', power_ratios, 'peakF', peakF, 'file', file, ...
										  'pre_free', pre_free, 'post_free', post_free, 'is_voc', is_voc, ...
                                          'original_idx', original_idx );
	
	%% this section actually just puts all of the info together
	% just this time, I won't store the vocs by map, but just in a simple structure..
	% I'll try the format of this one to match the format of the previous paper...
	% So I could reuse some code
	for m = 1 : numel( is_voc )
		struct_idx = struct_idx + 1;
		vocs_condensed_struct( struct_idx ) = struct( 'voc_start', voc_start(m), 'voc_end', voc_end(m), 'is_echo', is_echo(m), ...
												   'power_ratios', power_ratios(m), 'peakF', peakF(m), 'file', file, 'colID', colID, ... 
												   'pre_free', pre_free(m), 'post_free', post_free(m), 'is_voc', is_voc(m), ...
                                                   'original_idx', original_idx(m) );
    end
    
    % carry over the accumulted number of calls (for original_idx purposes)
    cumul_idx = cumul_idx + numel( aux.is_voc );
end

save vocs_condensed_data.mat vocs_condensed_map vocs_condensed_struct;
