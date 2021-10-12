% This script takes a wav wav, plots all possible channels, and then you
% can decide which one to keep as a microphone input (this obviously when
% there's only one bat and obviously for preliminary analyses)..

% In the end, it should produce a wave with a suffix "redux" that contains
% only one channel from the 4 channels recorded, with vocalization info

clc;
clear all;

%% plotting the wav
path2wav = 'D:\Work\Others\NeuropixelsPreliminary\DataPostProc\data\M2-DVAxis-210922-210922_g9_imec0\';
wavname = 'M2-DVAxis-210922-210922-G1-T19';

[x, fswav] = audioread( [path2wav, wavname, '.wav'] );
x = x ./ max( abs( x(:) ) );
tv = [0 : size(x, 1) - 1] ./ fswav;

figure(1); clf;
for m = 1 : size(x, 2)
    subplot( size(x, 2), 1, m ); axis tight;
    plot( tv, x( :, m ) ); ylim([-.5 .5])
end

%% saving the channel I only like
wav2save_name = [ wavname, '_redux.wav' ];
ch2save = 4; % by default, 4...
audiowrite( [path2wav, wav2save_name], x(:, ch2save), fswav );
