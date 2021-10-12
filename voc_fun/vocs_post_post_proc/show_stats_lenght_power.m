clc;
clear all;

% define where the data is.... (this is my particular ordering, tho)
rootwavfiles = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\data\M2-DVAxis-210922-210922_g9_imec0\';
datapath_matvars = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\prelim_voc_M2axis_Npixels\latest_basicdata\'
mapping_file = 'DataArrangement_dummy.xlsx';

load( [datapath_matvars, 'vocs_condensed_data.mat'] );

load call_lengths; load fft_vocs;

figure(1); clf;
edges_length = [ 0 : .25e-3 : 30e-3 ];
histogram( lengths_echo, edges_length, 'Normalization', 'probability' ); hold on;
histogram( lengths_nonecho, edges_length, 'Normalization', 'probability' ); %alpha 1;

figure(2); clf; hold on; 
tt{1} = lengths_echo'; tt{2} = lengths_nonecho';
violin( tt, 'xlabel', { 'echo', 'nonecho' }, 'facecolor', [0 0 1; 1 0 0], 'bw', .25e-3 );
scatter( normrnd( 1, 0.01, size(lengths_echo) ), lengths_echo, '.k' );
scatter( normrnd( 2, 0.01, size(lengths_nonecho) ), lengths_nonecho, '.k' );

% compare statistically the distribution of lengths for echo and non_echo
pval_len_echononecho = ranksum( lengths_echo, lengths_nonecho );

%% power analyses

[ Necho, Nnonecho, echo_idx, nonecho_idx ] = get_echo_nonecho_idxs( vocs_condensed_struct );

avg_fft_echo = mean( normalize( fft_chunk( echo_idx, : ), 2, 'range' ) );
avg_fft_nonecho = mean( normalize( fft_chunk( nonecho_idx, : ), 2, 'range' ) );

figure(3); subplot( 1, 2, 1 ); 
plot( f_target, avg_fft_echo );
hold on; plot( f_target, avg_fft_nonecho );
xlim( [0 125e3] );

subplot( 1, 2, 2 ); cla; hold on;
edges_pfreq = [ 0 : 2.5e3 : 125e3 ];
histogram( peak_freq( echo_idx ), edges_pfreq, 'Normalization', 'probability' );
histogram( peak_freq( nonecho_idx ), edges_pfreq, 'Normalization', 'probability' );
alpha 1;

pval_peakfreq_echononecho = ranksum( peak_freq( echo_idx ), peak_freq( nonecho_idx ) )

%% power and length combined in a 2D spectrogram

figure(4);  clf; hold on; 
% get me the bins for the bars
histogram2( peak_freq(echo_idx), lengths_echo, edges_pfreq, edges_length  );
histogram2(  peak_freq(nonecho_idx), lengths_nonecho, edges_pfreq, edges_length );
view(3); box on; 
yticks( [0 : .005 : .03] );
xticks( [0 : 10e3 : 125e3] ); xlim( [0 125e3] );
text( 60e3, 0.02, 30, sprintf( 'pval length: %e', pval_len_echononecho ) );
text( 60e3, 0.02, 40, sprintf( 'pval peak freq: %e', pval_peakfreq_echononecho ) );
