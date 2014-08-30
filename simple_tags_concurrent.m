% Example of the simplest call script for the gbnn network

% Clear things up
clear all; % don't forget to clear all; before, else some variables or sourcecode change may not be refreshed and the code you will run is the one from the cache, not the latest edition you did!
close all;

% Importing auxiliary functions
aux = gbnn_aux; % works with both MatLab and Octave

% Primary network params
m = 10E2;
c = 8;
l = 16;
Chi = 32;
erasures = 3;

tampered_messages_per_test = 100;
tests = 1;

iterations = 4;
gamma_memory = 1;
propagation_rule = 'sum';
filtering_rule = 'GWSTA';
filtering_rule_first_iteration = false;
enable_guiding = false;

% Concurrency params
concurrent_cliques = 3;
no_concurrent_overlap = false;

% Overlays / Tags
enable_overlays = true;
if enable_overlays; propagation_rule = 'overlays_ehsan2'; end;

% Concurrent disequilibrium trick
concurrent_disequilibrium = 1; % 1 for superscore mode, 2 for one fanal erasure, 3 for nothing at all just trying to decode one clique at a time without any trick, 0 to disable

% Verbose?
silent = false;

% == Launching the runs
tperf = cputime();
[cnetwork, thriftymessages, density] = gbnn_learn('m', m, 'l', l, 'c', c, 'Chi', Chi, 'enable_overlays', enable_overlays, 'silent', silent);

if ~silent
    printf('Minimum overlay: %i\n',  full(min(cnetwork.primary.net(cnetwork.primary.net > 0))));
end

error_rate = gbnn_test('cnetwork', cnetwork, 'thriftymessagestest', thriftymessages, ...
                                                                                  'iterations', iterations, ...
                                                                                  'tests', tests, 'tampered_messages_per_test', tampered_messages_per_test, ...
                                                                                  'enable_guiding', enable_guiding, 'filtering_rule', filtering_rule, 'propagation_rule', propagation_rule, 'erasures', erasures, 'gamma_memory', gamma_memory, ...
                                                                                  'concurrent_cliques', concurrent_cliques, 'no_concurrent_overlap', no_concurrent_overlap, 'concurrent_disequilibrium', concurrent_disequilibrium, ...
                                                                                  'silent', silent);

if ~silent
    aux.printcputime(cputime() - tperf, 'Total cpu time elapsed to do everything: %g seconds.\n'); aux.flushout(); % print total time elapsed
end

% The end!