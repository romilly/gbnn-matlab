% Test unit for the gbnn network matlab/octave package
% great to check compatibility between matlab/octave!

% Clear things up
clear all; % don't forget to clear all; before, else some variables or sourcecode change may not be refreshed and the code you will run is the one from the cache, not the latest edition you did!
close all;

% Importing auxiliary functions
aux = gbnn_aux; % works with both MatLab and Octave

% Basic network config
% Note: these parameters can be overwritten for specific test cases if you want.
m = 10E3; %1E4;
c = 8;
l = 32;
Chi = 64;
erasures = 3;
tampered_messages_per_test = 100;
silent = true;

% Setup the test cases
% Format: a big cell array, containing one cell array per test case, each test case containing 4 fields;
% 1- one string for the title
% 2- one cell array for the learning parameters (with named arguments format)
% 3- one cell array for the testing parameters
% 4- one function to assert/check the resulting error rate (if it ought to be within a certain bound) - Keep in mind that the result is a bit stochastic so you should make sure your bound is correct! (so that your assert won't be triggered off just because sometimes the result is out of your bound because of the usual network variability)
% Note: you can also overwrite basic parameters above (for example you can specify a different number of messages m to learn {'m', 20E1} just for one specific test case)
test_cases = { ...
                            { ...
                                ... % 1st test case
                                'filtering rule: GWsTA', ...
                                {}, ...
                                {'concurrent_cliques', 1, 'filtering_rule', 'GWsTA'}, ...
                                (@(x) x < 0.15) ...
                            }, ...
                            { ...
                                ... % 2nd test case
                                'filtering rule: WTA sparse no guiding', ...
                                {}, ...
                                {'concurrent_cliques', 1, 'filtering_rule', 'WTA'}, ...
                                (@(x) x == 1) ...
                            }, ...
                            { ...
                                ... % test case: WTA guided
                                'filtering rule: WTA sparse with guiding', ...
                                {}, ...
                                {'concurrent_cliques', 1, 'filtering_rule', 'WTA', 'enable_guiding', true}, ...
                                (@(x) x < 0.1) ...
                            }, ...
                            { ...
                                ... % test case: WTA in non sparse network
                                'filtering rule: WTA non sparse ', ...
                                {'m', 20E1, 'Chi', c}, ...
                                {'concurrent_cliques', 1, 'filtering_rule', 'WTA'}, ...
                                (@(x) x < 0.1) ...
                            }, ...
                            { ...
                                ... % test case: filtering rule: WsTA
                                'filtering rule: WsTA', ...
                                {}, ...
                                {'filtering_rule', 'WsTA', 'concurrent_cliques', 2}, ...
                                [] ...
                            }, ...
                            { ...
                                ... % test case: filtering rule: GWTA
                                'filtering rule: GWTA', ...
                                {}, ...
                                {'filtering_rule', 'GWTA'}, ...
                                [] ...
                            }, ...
                            { ...
                                ... % test case: filtering rule: kWTA
                                'filtering rule: kWTA', ...
                                {}, ...
                                {'filtering_rule', 'kWTA'}, ...
                                [] ...
                            }, ...
                            { ...
                                ... % test case: ml
                                'filtering rule: ML', ...
                                {}, ...
                                {'filtering_rule', 'ML', 'iterations', 1}, ...
                                (@(x) x < 0.05) ...
                            }, ...
                            { ...
                                ... % test case: concurrent + ml
                                'filtering rule: ML + concurrent', ...
                                {}, ...
                                {'concurrent_cliques', 2, 'filtering_rule', 'ML', 'iterations', 1}, ...
                                (@(x) x < 0.05) ...
                            }, ...
                            { ...
                                ... % test case: disequilibrium boost
                                'disequilibrium boost', ...
                                {}, ...
                                {'concurrent_cliques', 3, 'concurrent_disequilibrium', 1, 'filtering_rule', 'GWsTA', 'gamma_memory', 1, 'iterations', 5}, ...
                                (@(x) x < 0.40) ...
                            }, ...
                            { ...
                                ... % test case: disequilibrium no boost
                                'disequilibrium (no boost)', ...
                                {}, ...
                                {'concurrent_cliques', 3, 'concurrent_disequilibrium', 3, 'filtering_rule', 'GWsTA', 'gamma_memory', 1, 'iterations', 5}, ...
                                (@(x) x <= 0.90) ...
                            }, ...
                            { ...
                                ... % test case: M tags
                                'M tags', ...
                                {'m', 0.4, 'c', 8, 'l', 16, 'Chi', 32, 'enable_overlays', true}, ...
                                {'filtering_rule', 'GWsTA', 'gamma_memory', 0, 'iterations', 2, 'erasures', 2, 'enable_overlays', true, 'overlays_max', 0}, ...
                                (@(x) x < 0.05) ...
                            }, ...
                            { ...
                                ... % test case: 50 tags
                                '50 tags', ...
                                {'m', 0.4, 'c', 8, 'l', 16, 'Chi', 32, 'enable_overlays', true}, ...
                                {'filtering_rule', 'GWsTA', 'gamma_memory', 0, 'iterations', 2, 'erasures', 2, 'enable_overlays', true, 'overlays_max', 50}, ...
                                (@(x) x < 0.3) ...
                            }, ...
                            { ...
                                ... % test case: M tags + concurrent
                                'M tags + concurrent', ...
                                {'m', 0.2, 'c', 8, 'l', 16, 'Chi', 32, 'enable_overlays', true}, ...
                                {'concurrent_cliques', 2, 'filtering_rule', 'GWsTA', 'gamma_memory', 0, 'iterations', 2, 'enable_overlays', true, 'overlays_max', 0}, ...
                                (@(x) x < 0.5) ...
                            }, ...
                            { ...
                                ... % test case: M tags + concurrent + disequilibrium boost
                                'M tags + concurrent + disequilibrium boost', ...
                                {'m', 0.3, 'c', 8, 'l', 16, 'Chi', 32, 'enable_overlays', true}, ...
                                {'concurrent_cliques', 2, 'filtering_rule', 'GWsTA', 'gamma_memory', 1, 'iterations', 2, 'enable_overlays', true, 'overlays_max', 0, 'concurrent_disequilibrium', 1}, ...
                                (@(x) x < 0.55) ...
                            }, ...
                            { ...
                                ... % test case: M tags + concurrent + disequilibrium (no boost)
                                'M tags + concurrent + disequilibrium (no boost)', ...
                                {'m', 0.3, 'c', 8, 'l', 16, 'Chi', 32, 'enable_overlays', true}, ...
                                {'concurrent_cliques', 2, 'filtering_rule', 'GWsTA', 'gamma_memory', 1, 'iterations', 2, 'enable_overlays', true, 'overlays_max', 0, 'concurrent_disequilibrium', 3}, ...
                                (@(x) x < 0.55) ...
                            }, ...
                            { ...
                                ... % test case: A few obscure features
                                'Check that obscure features are working', ...
                                {}, ...
                                {'filtering_rule', 'GWsTA', 'residual_memory', 0.1, 'concurrent_cliques', 2, 'no_concurrent_overlap', true, 'enable_dropconnect', true, 'dropconnect_p', 0.4}, ...
                                [] ...
                            }, ...
                            { ...
                                ... % test case: A few more obscure features
                                'Check that obscure features are working - 2', ...
                                {}, ...
                                {'filtering_rule', 'GWsTA', 'concurrent_cliques', 2, 'concurrent_successive', true, 'tampering_type', 'noise', 'filtering_rule_first_iteration', 'GWTA', 'filtering_rule_last_iteration', 'GkWTA'}, ...
                                [] ...
                            } ...
                        };

% == Launching the runs
oktests = 0;
for i=1:numel(test_cases)
    all_args = test_cases{i};
    title_arg = all_args{1};
    learn_args = all_args{2};
    test_args = all_args{3};
    assert_func = all_args{4};

    printf('=================\n== Test case %i/%i: %s ==\n=================\n', i, numel(test_cases), title_arg); aux.flushout();
    tperf = cputime();
    [cnetwork, thriftymessages, density] = gbnn_learn('silent', silent, 'm', m, 'l', l, 'c', c, 'Chi', Chi, learn_args{:});
    error_rate = gbnn_test('silent', silent, 'cnetwork', cnetwork, 'thriftymessagestest', thriftymessages, 'tampered_messages_per_test', tampered_messages_per_test, 'erasures', erasures, test_args{:});
    % Assert: test the value of error rate to check that this is ok
    if isempty(assert_func)
        printf('Assert: NA\n');
        oktests = oktests + 1;
    else
        if assert_func(error_rate)
            printf('Assert: OK: %s\n', func2str(assert_func));
            oktests = oktests + 1;
        else
            printf('Assert: KO: %s\n', func2str(assert_func));
        end
    end
    aux.printcputime(cputime() - tperf, sprintf('Finished test case %i. %s', i, 'total cpu time elapsed: %g seconds.\n\n')); aux.flushout(); % print total time elapsed
end

printf('====================================\n');
printf('Total number of tests passed: %i/%i\n', oktests, numel(test_cases));
if oktests == numel(test_cases)
    printf('No error thus far, then alright! All test cases passed!\n');
else
    printf('Some assert were not fulfilled. Please check the assert condition or the code (either one is wrong).\n');
end

% The end!
