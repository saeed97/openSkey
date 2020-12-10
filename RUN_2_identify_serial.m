%% Define input & output directory
isLLSC = false;
if isLLSC
    inDir = [filesep 'home' filesep 'gridsan' filesep LL_USERNAME filesep 'OpenSkyNetwork_Data_shared' filesep '1_organize'];
    outDir = [filesep 'home' filesep 'gridsan' filesep LL_USERNAME filesep 'OpenSkyNetwork_Data_shared' filesep '2_identify'];
else
    inDir = [getenv('AEM_DIR_OPENSKY') filesep 'output' filesep '1_organize'];
    outDir = [getenv('AEM_DIR_OPENSKY') filesep 'output' filesep '2_identify'];
end

%% Call function
tic
[Tac_filter,listing] = identifyraw_2('inDir',inDir,...
    'keptTypes',["FixedWingMultiEngine";"FixedWingSingleEngine";"Rotorcraft"],...
    'isFilterHemiNW',true,...
    'isFilterFL180',true);

% Save
% For variables larger than 2GB use MAT-file version 7.3 or later.
save([outDir filesep sprintf('2_Tac_%s.mat',datestr(date,'YYYY-mm-DD'))],'Tac_filter','listing','-v7.3');
fprintf('RUN_2_identify_serial ran in %0.0f seconds\n',toc);

% Display some stats
fprintf('Total raw observations = %i\n', sum(Tac_filter.nReports));
fprintf('# unique icao24 = %i\n', numel(unique(Tac_filter.icao24)));
fprintf('# unique aircraft models = %i\n', numel(unique(Tac_filter.acModel)));
