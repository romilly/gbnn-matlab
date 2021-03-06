% Simple usage of Maximum Likelihood filtering rule

% Clear things up
clear all; % don't forget to clear all; before, else some variables or sourcecode change may not be refreshed and the code you will run is the one from the cache, not the latest edition you did!
close all;

% Addpath of the whole library (this allows for modularization: we can place the core library into a separate folder)
if ~exist('gbnn_aux.m','file')
    %restoredefaultpath;
    addpath(genpath(strcat(cd(fileparts(mfilename('fullpath'))),'/gbnn-core/')));
end

% Importing auxiliary functions
aux = gbnn_aux; % works with both MatLab and Octave

% Vars config, tweak the stuff here
m = 2E2 % 0.5E2 7E2; 14E2
c = 5;
l = 12;
Chi = 18;
erasures = 1;

tampered_messages_per_test = 30;
concurrent_cliques = 2; % ML also works for concurrent cliques!
no_concurrent_overlap = false;
concurrent_disequilibrium = false;

iterations = 1; % no need for more than 1 iteration with ML
filtering_rule = 'ML';

% == Launching the runs
tperf = cputime();
[cnetwork, thriftymessages, density] = gbnn_learn('m', m, 'l', l, 'c', c, 'Chi', Chi);
error_rate = gbnn_test('cnetwork', cnetwork, 'thriftymessagestest', thriftymessages, 'tampered_messages_per_test', tampered_messages_per_test, 'filtering_rule', filtering_rule, 'concurrent_cliques', concurrent_cliques, 'iterations', iterations, 'erasures', erasures, 'no_concurrent_overlap', no_concurrent_overlap, 'concurrent_disequilibrium', concurrent_disequilibrium);
aux.printcputime(cputime() - tperf, 'Total cpu time elapsed to do everything: %g seconds.\n'); aux.flushout(); % print total time elapsed

% The end!
